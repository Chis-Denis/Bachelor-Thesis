import '../../domain/auth/auth_repository.dart';
import '../../domain/constants/meal_constants.dart';
import '../../domain/foods/food.dart';
import '../../domain/foods/food_data_type.dart';
import '../../domain/foods/food_repository.dart';
import '../../domain/foods/food_source.dart';
import '../../domain/meals/meal_draft.dart';
import '../../domain/meals/meal_repository.dart';
import '../../domain/meals/meal_type.dart';
import '../../domain/ordering/new_order.dart';
import '../../domain/ordering/order_repository.dart';
import '../../domain/shared/failures.dart';
import '../../domain/shared/quantity.dart';
import '../../domain/shared/unit_of_work.dart';
import '../auth/session_store.dart';
import '../auth/user_dto.dart';
import '../meals/load_meals.dart';
import '../shared/operation_result.dart';
import 'cart_service.dart';

class PlaceOrder {
  final CartService _cart;
  final SessionStore _session;
  final AuthRepository _auth;
  final OrderRepository _orders;
  final MealRepository _meals;
  final FoodRepository _foods;
  final UnitOfWork _unitOfWork;
  final LoadMeals _loadMeals;

  const PlaceOrder(
    this._cart,
    this._session,
    this._auth,
    this._orders,
    this._meals,
    this._foods,
    this._unitOfWork,
    this._loadMeals,
  );

  Future<OperationResult<void>> call() async {
    try {
      if (_cart.isEmpty) throw const EmptyOrderFailure();
      final userId = _session.userId;
      if (userId == null) throw const NotAuthenticatedFailure();

      final account = await _auth.findById(userId);
      if (account == null) throw const AccountNotFoundFailure();

      final total = _cart.total;
      if (account.user.balance < total) {
        throw const InsufficientFundsFailure(
          'You do not have enough funds to place this order',
        );
      }

      final now = DateTime.now();
      final restaurant = _cart.restaurant;
      final lines = _cart.lines;
      final newOrder = NewOrder(
        restaurantId: restaurant?.id,
        restaurantName: restaurant?.name ?? '',
        subtotal: _cart.subtotal,
        deliveryFee: _cart.deliveryFee,
        total: total,
        createdAt: now,
        lines: [
          for (final line in lines)
            NewOrderLine(
              menuItemId: line.item.id,
              name: line.item.name,
              description: line.item.description,
              price: line.item.price,
              quantity: line.quantity.toDouble(),
              macros: line.item.macros,
            ),
        ],
      );
      final newBalance = account.user.balance - total;
      final mealType = MealType.defaultForHour(now.hour);

      await _unitOfWork.execute(() async {
        await _orders.create(userId: userId, order: newOrder);
        await _auth.updateBalance(userId: userId, balance: newBalance);
        for (final line in lines) {
          final quantity = line.quantity.toDouble();
          final scaled = line.item.macros.scale(quantity);
          await _meals.add(
            userId: userId,
            draft: MealDraft(
              name: line.item.name,
              type: mealType,
              quantity: Quantity(quantity),
              unit: MealConstants.defaultUnit,
              macros: scaled,
              date: now,
            ),
          );
          await _foods.upsert(
            userId: userId,
            food: Food(
              name: line.item.name,
              macros: scaled,
              servingSize: quantity,
              servingUnit: MealConstants.defaultUnit,
              source: FoodSource.local,
              dataType: FoodDataType.custom,
            ),
          );
        }
      });

      _session.set(UserDto.fromDomain(account.user.withBalance(newBalance)));
      _cart.clear();
      await _loadMeals();
      return const OperationResult.ok();
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not place order');
    }
  }
}
