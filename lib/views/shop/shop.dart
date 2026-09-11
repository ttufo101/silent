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

enum _PlanFilter { all, time, traffic }

class ShopView extends ConsumerStatefulWidget {
  const ShopView({super.key});

  @override
  ConsumerState<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends ConsumerState<ShopView> {
  var _selectedFilter = _PlanFilter.all;

  void _selectFilter(_PlanFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
  }

  void _goBack() {
    ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansProvider);
    final isMobile = ref.watch(isMobileViewProvider);
    return Scaffold(
      backgroundColor:
          isMobile && Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFEEEEEE)
          : context.tDesign.pageBackground,
      appBar: isMobile
          ? AppBar(
              toolbarHeight: 48,
              centerTitle: true,
              leadingWidth: 48,
              automaticallyImplyLeading: false,
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
            )
          : null,
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 1080,
              ),
              child: _PlanFilterTabs(
                desktop: !isMobile,
                selectedFilter: _selectedFilter,
                onSelected: _selectFilter,
              ),
            ),
          ),
          Expanded(
            child: plans.when(
              data: (value) => _PlanList(
                plans: _filterPlans(value, _selectedFilter),
                desktop: !isMobile,
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

class _PlanFilterTabs extends StatelessWidget {
  final bool desktop;
  final _PlanFilter selectedFilter;
  final ValueChanged<_PlanFilter> onSelected;

  const _PlanFilterTabs({
    required this.desktop,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (_PlanFilter.all, context.appLocalizations.shopAll),
      (_PlanFilter.time, context.appLocalizations.shopTime),
      (_PlanFilter.traffic, context.appLocalizations.shopTraffic),
    ];
    return ColoredBox(
      color: context.tDesign.container,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
          final width = math.max(constraints.maxWidth / 3, 112 * scale);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tabs
                  .map((tab) {
                    final selected = selectedFilter == tab.$1;
                    return SizedBox(
                      width: width,
                      height: desktop ? 40 : 48,
                      child: Semantics(
                        button: true,
                        selected: selected,
                        child: InkWell(
                          onTap: () => onSelected(tab.$1),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  tab.$2,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      (desktop
                                              ? context.textTheme.bodyLarge
                                              : context.textTheme.titleMedium)
                                          ?.copyWith(
                                            color: selected
                                                ? context.colorScheme.primary
                                                : context.colorScheme.onSurface,
                                          ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 16,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? context.colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          );
        },
      ),
    );
  }
}

class _PlanList extends StatelessWidget {
  final List<Plan> plans;
  final bool desktop;

  const _PlanList({required this.plans, required this.desktop});

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return Center(child: Text(context.appLocalizations.shopNoPlans));
    }
    if (desktop) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = math.min(constraints.maxWidth - 48, 1080.0);
          final columns = contentWidth >= 1000 ? 3 : 2;
          final itemWidth = (contentWidth - (columns - 1) * 16) / columns;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final plan in plans)
                      SizedBox(
                        width: itemWidth,
                        child: PlanCard(plan: plan, desktop: true),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      itemCount: plans.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (_, index) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: PlanCard(plan: plans[index]),
        ),
      ),
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
  final bool desktop;

  const PlanCard({super.key, required this.plan, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: desktop ? 180 : 197),
      padding: EdgeInsets.fromLTRB(
        desktop ? 16 : 18,
        12,
        12,
        desktop ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: context.tDesign.container,
        borderRadius: BorderRadius.circular(9),
        border: desktop
            ? Border.all(color: context.tDesign.componentStroke)
            : null,
        boxShadow: desktop
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 4,
                  spreadRadius: -1,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final sideBySide = constraints.maxWidth >= 275 * scale;
          final price = Text(
            _formatPrice(context, plan),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF1265E8),
              fontWeight: FontWeight.w600,
            ),
          );
          final name = Text(
            plan.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          );
          final pricePainter = TextPainter(
            text: TextSpan(
              text: _formatPrice(context, plan),
              style: context.textTheme.titleMedium,
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            locale: Localizations.localeOf(context),
          )..layout();
          final stackedHeader = pricePainter.width > constraints.maxWidth * 0.4;
          pricePainter.dispose();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stackedHeader)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [name, const SizedBox(height: 8), price],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: name),
                    const SizedBox(width: 16),
                    price,
                  ],
                ),
              const SizedBox(height: 18),
              if (sideBySide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _PlanBenefits(plan: plan)),
                    const SizedBox(width: 12),
                    _PurchaseDisplay(desktop: desktop),
                  ],
                )
              else ...[
                _PlanBenefits(plan: plan),
                const SizedBox(height: 16),
                const Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _PurchaseDisplay(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PlanBenefits extends StatelessWidget {
  final Plan plan;

  const _PlanBenefits({required this.plan});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      (
        'assets/images/shop/time.svg',
        _formatDays(context, plan.durationDays),
        context.appLocalizations.shopValidity,
      ),
      (
        'assets/images/shop/traffic.svg',
        _formatTraffic(context, plan.trafficBytes),
        context.appLocalizations.shopTrafficLabel,
      ),
      (
        'assets/images/shop/devices.svg',
        context.appLocalizations.shopDeviceCount('${plan.maxDevices}'),
        context.appLocalizations.shopDevices,
      ),
      (
        'assets/images/shop/bandwidth.svg',
        _formatBandwidth(context, plan.speedLimitMbps),
        context.appLocalizations.shopBandwidth,
      ),
    ];
    return Column(
      children: [
        _BenefitRow(benefits: benefits.take(2).toList(growable: false)),
        const SizedBox(height: 8),
        _BenefitRow(benefits: benefits.skip(2).toList(growable: false)),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final List<(String, String, String)> benefits;

  const _BenefitRow({required this.benefits});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < benefits.length; index++) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: _PlanBenefit(
              asset: benefits[index].$1,
              value: benefits[index].$2,
              label: benefits[index].$3,
            ),
          ),
        ],
      ],
    );
  }
}

class _PlanBenefit extends StatelessWidget {
  final String asset;
  final String value;
  final String label;

  const _PlanBenefit({
    required this.asset,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: SvgPicture.asset(asset, width: 18, height: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                softWrap: true,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                softWrap: true,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PurchaseDisplay extends StatelessWidget {
  final bool desktop;

  const _PurchaseDisplay({this.desktop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 72, minHeight: desktop ? 40 : 44),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: desktop ? 8 : 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        context.appLocalizations.shopBuy,
        maxLines: 1,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

List<Plan> _filterPlans(List<Plan> plans, _PlanFilter filter) {
  return switch (filter) {
    _PlanFilter.all => plans,
    _PlanFilter.time =>
      plans.where((plan) => plan.type == PlanType.time).toList(growable: false),
    _PlanFilter.traffic =>
      plans
          .where((plan) => plan.type == PlanType.traffic)
          .toList(growable: false),
  };
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
  if (bytes == 0) return context.appLocalizations.shopUnlimitedShort;
  final gigabytes = bytes / (1024 * 1024 * 1024);
  final value = gigabytes == gigabytes.roundToDouble()
      ? '${gigabytes.toInt()}'
      : gigabytes.toStringAsFixed(1);
  return context.appLocalizations.shopTrafficGigabytes(value);
}

String _formatBandwidth(BuildContext context, int mbps) {
  return mbps == 0
      ? context.appLocalizations.shopUnlimitedShort
      : context.appLocalizations.shopBandwidthShort('$mbps');
}
