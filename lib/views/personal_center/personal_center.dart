import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/starcore/models/user_info.dart';
import 'package:fl_clash/starcore/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/personal_center/change_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonalCenterView extends ConsumerStatefulWidget {
  const PersonalCenterView({super.key});

  @override
  ConsumerState<PersonalCenterView> createState() => _PersonalCenterViewState();
}

class _PersonalCenterViewState extends ConsumerState<PersonalCenterView> {
  bool _loggingOut = false;
  bool _refreshingPlan = false;

  Future<void> _refresh(String uid) {
    return ref.refresh(userInfoProvider(uid).future);
  }

  void _openShop() {
    ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.shop);
  }

  Future<void> _refreshPlan(String uid) async {
    if (_refreshingPlan) return;
    setState(() => _refreshingPlan = true);
    try {
      await ref.read(serverProfileSyncProvider).synchronize();
      ref.invalidate(userInfoProvider(uid));
      await ref.read(userInfoProvider(uid).future);
    } catch (_) {
      if (mounted) {
        context.showNotifier(context.appLocalizations.personalLoadFailed);
      }
    } finally {
      if (mounted) setState(() => _refreshingPlan = false);
    }
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    final confirmed = await globalState.showMessage(
      title: context.appLocalizations.personalLogout,
      message: TextSpan(
        text: context.appLocalizations.personalLogoutDescription,
      ),
      confirmText: context.appLocalizations.personalLogout,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loggingOut = true);
    try {
      await ref.read(authControllerProvider).logout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  void _openChangePassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ChangePasswordView()));
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.read(authControllerProvider).session;
    final uid = session?.uid ?? '';
    final userInfo = ref.watch(userInfoProvider(uid));
    final loadedUserInfo = userInfo.asData?.value;
    final isMobile = ref.watch(isMobileViewProvider);
    final email = loadedUserInfo?.username.isNotEmpty == true
        ? loadedUserInfo!.username
        : session?.email ?? '';
    return Scaffold(
      backgroundColor:
          isMobile && Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFEEEEEE)
          : context.tDesign.pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(uid),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: isMobile
                ? const EdgeInsets.only(top: 7, bottom: 24)
                : const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              _ProfileWidth(child: _AccountHeader(email: email)),
              SizedBox(height: isMobile ? 17 : 16),
              _ProfileWidth(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 0,
                  ),
                  child: _PlanSection(
                    value: userInfo,
                    onRetry: () => ref.invalidate(userInfoProvider(uid)),
                    onOpenShop: _openShop,
                    onRefreshPlan: () => _refreshPlan(uid),
                    refreshingPlan: _refreshingPlan,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 32 : 16),
              _ProfileWidth(
                child: _SectionLabel(label: context.appLocalizations.more),
              ),
              _ProfileWidth(
                child: _MenuGroup(
                  isMobile: isMobile,
                  loggingOut: _loggingOut,
                  onChangePassword: _openChangePassword,
                  onLogout: _loggingOut ? null : _logout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileWidth extends StatelessWidget {
  const _ProfileWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width > 600;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: desktop ? 1080 : 480),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width > 600;
    return Column(
      children: [
        Container(
          width: desktop ? 56 : 64,
          height: desktop ? 56 : 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFD9E1FF),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/images/personal/user.svg',
            width: desktop ? 22 : 24,
            height: desktop ? 24 : 27,
          ),
        ),
        SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({
    required this.value,
    required this.onRetry,
    required this.onOpenShop,
    required this.onRefreshPlan,
    required this.refreshingPlan,
  });

  final AsyncValue<UserInfo> value;
  final VoidCallback onRetry;
  final VoidCallback onOpenShop;
  final Future<void> Function() onRefreshPlan;
  final bool refreshingPlan;

  @override
  Widget build(BuildContext context) {
    final info = value.asData?.value;
    final plan = info?.currentPlan;
    final desktop = MediaQuery.sizeOf(context).width > 600;
    return Container(
      constraints: BoxConstraints(minHeight: desktop ? 128 : 184),
      padding: const EdgeInsets.fromLTRB(9, 11, 7, 13),
      decoration: _profileCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (desktop)
                Text(
                  context.appLocalizations.personalPlan,
                  style: _sectionTitleStyle(context),
                )
              else
                Expanded(
                  child: Text(
                    context.appLocalizations.personalPlan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _sectionTitleStyle(context),
                  ),
                ),
              if (plan != null) ...[
                SizedBox(width: desktop ? 16 : 20),
                Expanded(
                  child: Text(
                    plan.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _sectionTitleStyle(context),
                  ),
                ),
              ] else if (!desktop)
                const Spacer(),
            ],
          ),
          SizedBox(height: desktop ? 22 : 26),
          if (value.hasError && info == null)
            _PlanStatus(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.appLocalizations.personalLoadFailed,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRetry,
                    child: Text(context.appLocalizations.retry),
                  ),
                ],
              ),
            )
          else if (value.isLoading && info == null)
            const _PlanStatus(child: CircularProgressIndicator())
          else if (info == null || plan == null)
            _PlanStatus(
              child: _NoPlanState(
                desktop: desktop,
                refreshing: refreshingPlan,
                onOpenShop: onOpenShop,
                onRefresh: onRefreshPlan,
              ),
            )
          else
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 3),
              child: _PlanDetails(info: info),
            ),
        ],
      ),
    );
  }
}

class _NoPlanState extends StatelessWidget {
  const _NoPlanState({
    required this.desktop,
    required this.refreshing,
    required this.onOpenShop,
    required this.onRefresh,
  });

  final bool desktop;
  final bool refreshing;
  final VoidCallback onOpenShop;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final actions = [
      SizedBox(
        width: desktop ? 144 : double.infinity,
        height: 44,
        child: FilledButton(
          onPressed: onOpenShop,
          child: Text(context.appLocalizations.personalViewPlans),
        ),
      ),
      TextButton(
        onPressed: refreshing ? null : onRefresh,
        child: refreshing
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(context.appLocalizations.personalRefreshPlan),
      ),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, desktop ? 8 : 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: desktop ? 40 : 48,
            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            context.appLocalizations.personalNoActivePlan,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.appLocalizations.personalNoPlanDescription,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: desktop ? 14 : 18),
          if (desktop)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                actions.first,
                const SizedBox(width: 8),
                actions.last,
              ],
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                actions.first,
                const SizedBox(height: 4),
                actions.last,
              ],
            ),
        ],
      ),
    );
  }
}

class _PlanStatus extends StatelessWidget {
  const _PlanStatus({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: Center(child: child),
    );
  }
}

class _PlanDetails extends StatelessWidget {
  const _PlanDetails({required this.info});

  final UserInfo info;

  @override
  Widget build(BuildContext context) {
    final plan = info.currentPlan!;
    final features = [
      (
        'assets/images/shop/time.svg',
        context.appLocalizations.personalRemainingDays,
        context.appLocalizations.shopDayCount('${info.remainingDays}'),
      ),
      (
        'assets/images/shop/traffic.svg',
        context.appLocalizations.personalRemainingTraffic,
        info.unlimited
            ? context.appLocalizations.shopUnlimited
            : _formatTraffic(context, info.remainingTrafficBytes),
      ),
      (
        'assets/images/shop/devices.svg',
        context.appLocalizations.shopDevices,
        plan.maxDevices == 0
            ? context.appLocalizations.personalUnlimitedDevices
            : '${info.boundDeviceCount}/${plan.maxDevices}',
      ),
      (
        'assets/images/shop/bandwidth.svg',
        context.appLocalizations.shopBandwidth,
        plan.speedLimitMbps == 0
            ? context.appLocalizations.personalUnlimitedSpeed
            : context.appLocalizations.shopBandwidthMbps(
                '${plan.speedLimitMbps}',
              ),
      ),
    ];
    return _FeatureGrid(features: features);
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.features});

  final List<(String, String, String)> features;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final fourColumns = constraints.maxWidth >= 720 * scale;
        if (fourColumns) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < features.length; index++) ...[
                if (index > 0) const SizedBox(width: 20),
                Expanded(
                  child: _ProfileFeature(
                    asset: features[index].$1,
                    label: features[index].$2,
                    value: features[index].$3,
                  ),
                ),
              ],
            ],
          );
        }
        final twoColumns = constraints.maxWidth >= 300 * scale;
        if (!twoColumns) {
          return Column(
            children: [
              for (var index = 0; index < features.length; index++) ...[
                if (index > 0) const SizedBox(height: 12),
                _ProfileFeature(
                  asset: features[index].$1,
                  label: features[index].$2,
                  value: features[index].$3,
                ),
              ],
            ],
          );
        }
        return Column(
          children: [
            _FeatureRow(features: features.take(2).toList(growable: false)),
            const SizedBox(height: 10),
            _FeatureRow(features: features.skip(2).toList(growable: false)),
          ],
        );
      },
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.features});

  final List<(String, String, String)> features;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < features.length; index++) ...[
          if (index > 0) const SizedBox(width: 20),
          Expanded(
            child: _ProfileFeature(
              asset: features[index].$1,
              label: features[index].$2,
              value: features[index].$3,
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileFeature extends StatelessWidget {
  const _ProfileFeature({
    required this.asset,
    required this.label,
    required this.value,
  });

  final String asset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(asset, width: 28, height: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  softWrap: true,
                  style: context.textTheme.bodyMedium,
                ),
                Text(
                  value,
                  softWrap: true,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({
    required this.isMobile,
    required this.loggingOut,
    required this.onChangePassword,
    required this.onLogout,
  });

  final bool isMobile;
  final bool loggingOut;
  final VoidCallback onChangePassword;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(isMobile ? 0 : 9);
    return Column(
      children: [
        ClipRRect(
          borderRadius: borderRadius,
          child: Material(
            color: context.tDesign.container,
            child: Column(
              children: [
                _MenuRow(label: context.appLocalizations.personalOrders),
                const Divider(height: 0.5, indent: 16),
                _MenuRow(
                  label: context.appLocalizations.personalChangePassword,
                  onTap: onChangePassword,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Material(
            color: context.tDesign.container,
            child: _MenuRow(
              iconAsset: 'assets/images/personal/logout.svg',
              label: context.appLocalizations.personalLogout,
              destructive: true,
              loading: loggingOut,
              onTap: onLogout,
              showChevron: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    this.iconAsset,
    this.onTap,
    this.destructive = false,
    this.loading = false,
    this.showChevron = true,
  });

  final String? iconAsset;
  final String label;
  final VoidCallback? onTap;
  final bool destructive;
  final bool loading;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? context.colorScheme.error
        : context.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).width > 600 ? 48 : 56,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (loading)
                SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else if (iconAsset != null)
                SizedBox.square(
                  dimension: 24,
                  child: Center(
                    child: SvgPicture.asset(iconAsset!, width: 19, height: 19),
                  ),
                ),
              if (loading || iconAsset != null) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  softWrap: true,
                  style: context.textTheme.bodyLarge?.copyWith(color: color),
                ),
              ),
              if (showChevron)
                SizedBox.square(
                  dimension: 24,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/personal/chevron_right.svg',
                      width: 9,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSurface.withValues(alpha: 0.4),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _profileCardDecoration(BuildContext context) {
  final desktop = MediaQuery.sizeOf(context).width > 600;
  return BoxDecoration(
    color: context.tDesign.container,
    borderRadius: BorderRadius.circular(9),
    border: desktop ? Border.all(color: context.tDesign.componentStroke) : null,
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
  );
}

TextStyle? _sectionTitleStyle(BuildContext context) {
  return context.textTheme.titleMedium?.copyWith(
    color: context.colorScheme.primary,
    fontWeight: FontWeight.w600,
  );
}

String _formatTraffic(BuildContext context, int bytes) {
  final gigabytes = bytes / (1024 * 1024 * 1024);
  final value = gigabytes == gigabytes.roundToDouble()
      ? '${gigabytes.toInt()}'
      : gigabytes.toStringAsFixed(1);
  return context.appLocalizations.shopTrafficGigabytes(value);
}
