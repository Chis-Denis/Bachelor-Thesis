import 'package:flutter/material.dart';

import '../../application/ordering/cart_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/money_format.dart';
import '../design/design.dart';
import 'checkout_screen.dart';

class CartCompleteBar extends StatelessWidget {
  const CartCompleteBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.of(context).cartService;
    return StreamBuilder<CartDto>(
      stream: cart.state.changes,
      initialData: cart.current,
      builder: (context, snapshot) {
        final data = snapshot.data ?? CartDto.empty();
        if (data.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: SizedBox(
              height: AppSizes.buttonHeight,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.textOnDark,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.all8,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0x33FFFFFF),
                        borderRadius: AppRadii.pill,
                      ),
                      child: Text(
                        '${data.itemCount}',
                        style: const TextStyle(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        'Complete order',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formatLei(data.total),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
