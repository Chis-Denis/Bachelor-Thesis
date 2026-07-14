import '../eligible_menu_item.dart';

class BudgetFilter {
  const BudgetFilter();

  List<EligibleMenuItem> apply(
    List<EligibleMenuItem> items,
    double walletBalance,
  ) {
    return items.where((item) => item.price <= walletBalance).toList();
  }
}
