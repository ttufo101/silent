import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoSubscriptionView extends ConsumerStatefulWidget {
  const NoSubscriptionView({super.key});

  @override
  ConsumerState<NoSubscriptionView> createState() => _NoSubscriptionViewState();
}

class _NoSubscriptionViewState extends ConsumerState<NoSubscriptionView> {
  bool _refreshing = false;

  void _openShop() {
    ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.shop);
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await ref.read(serverProfileSyncProvider).synchronize();
      ref.read(serverProfileSyncErrorProvider.notifier).set(null);
    } catch (error) {
      ref.read(serverProfileSyncErrorProvider.notifier).set(error.toString());
      if (mounted) {
        context.showNotifier(context.appLocalizations.serverProfileSyncFailed);
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tDesign.pageBackground,
      body: SafeArea(
        child: Align(
          alignment: const Alignment(0, 0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.appLocalizations.subscriptionUnavailableTitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    context.appLocalizations.subscriptionUnavailableDescription,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 56),
                  SizedBox(
                    width: 230,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _openShop,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined, size: 22),
                      label: Text(
                        context.appLocalizations.subscriptionPurchasePlan,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _refreshing ? null : _refresh,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _refreshing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colorScheme.primary,
                            ),
                          )
                        : Text(
                            context.appLocalizations.subscriptionRefresh,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: context.colorScheme.primary,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
