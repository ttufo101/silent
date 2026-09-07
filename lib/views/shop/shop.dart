import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/starcore/models/plan.dart';
import 'package:fl_clash/starcore/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ShopView extends ConsumerStatefulWidget {
  const ShopView({super.key});

  @override
  ConsumerState<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends ConsumerState<ShopView> {
  var _selectedType = PlanType.time;

  void _selectType(PlanType type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
    });
  }

  void _goBack() {
    ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansProvider);
    return Scaffold(
      backgroundColor: context.tDesign.pageBackground,
      appBar: AppBar(
        toolbarHeight: 48,
        centerTitle: true,
        leadingWidth: 48,
        leading: IconButton(
          onPressed: _goBack,
          icon: SvgPicture.asset(
            'assets/images/shop/chevron_left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(context.appLocalizations.shopPlanTitle),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _PlanTypeTabs(selectedType: _selectedType, onSelected: _selectType),
          Expanded(
            child: plans.when(
              data: (value) => _PlanList(
                plans: value
                    .where((plan) => plan.type == _selectedType)
                    .toList(growable: false),
              ),
              error: (_, _) =>
                  _PlanLoadError(onRetry: () => ref.invalidate(plansProvider)),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTypeTabs extends StatelessWidget {
  final PlanType selectedType;
  final ValueChanged<PlanType> onSelected;

  const _PlanTypeTabs({required this.selectedType, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.tDesign.container,
        border: Border(
          bottom: BorderSide(
            color: context.tDesign.componentStroke,
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: _PlanTypeTab(
                label: context.appLocalizations.shopTime,
                selected: selectedType == PlanType.time,
                onTap: () => onSelected(PlanType.time),
              ),
            ),
            Expanded(
              child: _PlanTypeTab(
                label: context.appLocalizations.shopTraffic,
                selected: selectedType == PlanType.traffic,
                onTap: () => onSelected(PlanType.traffic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTypeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PlanTypeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: selected
                  ? context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.primary,
                    )
                  : context.textTheme.bodyLarge,
            ),
            if (selected)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanList extends StatelessWidget {
  final List<Plan> plans;

  const _PlanList({required this.plans});

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return Center(child: Text(context.appLocalizations.shopNoPlans));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: plans.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, index) => PlanCard(plan: plans[index]),
    );
  }
}

class _PlanLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _PlanLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.appLocalizations.shopLoadFailed),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(context.appLocalizations.retry),
          ),
        ],
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final Plan plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: ColoredBox(
        color: context.tDesign.pageBackground,
        child: Column(
          children: [
            _PlanHeader(plan: plan),
            const SizedBox(height: 1),
            _PlanDetails(plan: plan),
            const SizedBox(height: 1),
            const _PurchaseDisplay(),
          ],
        ),
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  final Plan plan;

  const _PlanHeader({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: context.tDesign.container,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              plan.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _formatPrice(context, plan),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDetails extends StatelessWidget {
  final Plan plan;

  const _PlanDetails({required this.plan});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.tDesign.container,
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              children: [
                Expanded(
                  child: _PlanFeature(
                    asset: 'assets/images/shop/time.svg',
                    label: context.appLocalizations.shopDays,
                    value: _formatDays(context, plan.durationDays),
                  ),
                ),
                Expanded(
                  child: _PlanFeature(
                    asset: 'assets/images/shop/traffic.svg',
                    label: context.appLocalizations.shopTraffic,
                    value: _formatTraffic(context, plan.trafficBytes),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            child: Row(
              children: [
                Expanded(
                  child: _PlanFeature(
                    asset: 'assets/images/shop/devices.svg',
                    label: context.appLocalizations.shopDevices,
                    value: '${plan.maxDevices}',
                  ),
                ),
                Expanded(
                  child: _PlanFeature(
                    asset: 'assets/images/shop/bandwidth.svg',
                    label: context.appLocalizations.shopBandwidth,
                    value: _formatBandwidth(context, plan.speedLimitMbps),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  final String asset;
  final String label;
  final String value;

  const _PlanFeature({
    required this.asset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.tDesign.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SvgPicture.asset(asset, width: 28, height: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseDisplay extends StatelessWidget {
  const _PurchaseDisplay();

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.colorScheme.brightness == Brightness.light
        ? const Color(0xFFD9E1FF)
        : context.colorScheme.primaryContainer;
    return Container(
      height: 44,
      alignment: Alignment.center,
      color: backgroundColor,
      child: Text(
        context.appLocalizations.shopBuyNow,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}

String _formatPrice(BuildContext context, Plan plan) {
  final currency = plan.currency.toUpperCase();
  final fractionDigits = const {'JPY', 'KRW'}.contains(currency) ? 0 : 2;
  final unit = math.pow(10, fractionDigits).toInt();
  final decimalDigits = fractionDigits > 0 && plan.priceAmount % unit == 0
      ? 1
      : fractionDigits;
  return NumberFormat.simpleCurrency(
    locale: Localizations.localeOf(context).toLanguageTag(),
    name: currency,
    decimalDigits: decimalDigits,
  ).format(plan.priceAmount / unit);
}

String _formatDays(BuildContext context, int days) {
  return days == 0
      ? context.appLocalizations.shopUnlimited
      : context.appLocalizations.shopDayCount('$days');
}

String _formatTraffic(BuildContext context, int bytes) {
  if (bytes == 0) return context.appLocalizations.shopUnlimited;
  final gigabytes = bytes / (1024 * 1024 * 1024);
  final value = gigabytes == gigabytes.roundToDouble()
      ? '${gigabytes.toInt()}'
      : gigabytes.toStringAsFixed(1);
  return context.appLocalizations.shopTrafficGigabytes(value);
}

String _formatBandwidth(BuildContext context, int mbps) {
  return mbps == 0
      ? context.appLocalizations.shopUnlimited
      : context.appLocalizations.shopBandwidthMbps('$mbps');
}
