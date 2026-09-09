import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SubscriptionAccessStatus { checking, active, inactive }

class SubscriptionAccessStatusNotifier
    extends Notifier<SubscriptionAccessStatus> {
  @override
  SubscriptionAccessStatus build() => SubscriptionAccessStatus.checking;

  void set(SubscriptionAccessStatus value) {
    state = value;
  }

  void reset() {
    state = SubscriptionAccessStatus.checking;
  }
}

final subscriptionAccessStatusProvider =
    NotifierProvider<
      SubscriptionAccessStatusNotifier,
      SubscriptionAccessStatus
    >(SubscriptionAccessStatusNotifier.new);
