import '../shared/money.dart';

class WalletConstants {
  WalletConstants._();

  static const double initialBalanceAmount = 200;
  static const Money initialBalance = Money(initialBalanceAmount);

  static const List<double> topUpPresets = [50, 100, 200];
  static const double maxTopUpAmount = 10000;
}
