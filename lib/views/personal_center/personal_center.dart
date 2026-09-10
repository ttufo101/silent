import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/starcore/models/user_info.dart';
import 'package:fl_clash/starcore/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
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

  Future<void> _refresh(String uid) {
    return ref.refresh(userInfoProvider(uid).future);
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

  void _openAbout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AboutView()));
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
                : const EdgeInsets.symmetric(vertical: 32),
            children: [
              _ProfileWidth(child: _AccountHeader(email: email)),
              const SizedBox(height: 12),
              _ProfileWidth(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _PlanSection(
                    value: userInfo,
                    onRetry: () => ref.invalidate(userInfoProvider(uid)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _ProfileWidth(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _OrdersSection(),
                ),
              ),
              const SizedBox(height: 8),
              _ProfileWidth(
                child: _SectionLabel(label: context.appLocalizations.more),
              ),
              _ProfileWidth(
                child: _MenuGroup(
                  loggingOut: _loggingOut,
                  onChangePassword: _openChangePassword,
                  onOpenAbout: _openAbout,
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
        constraints: BoxConstraints(maxWidth: desktop ? 1040 : 480),
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
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFD9E1FF),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/images/personal/user.svg',
            width: 24,
            height: 27,
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({required this.value, required this.onRetry});

  final AsyncValue<UserInfo> value;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final info = value.asData?.value;
    final plan = info?.currentPlan;
    return Container(
      constraints: const BoxConstraints(minHeight: 184),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: _profileCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.appLocalizations.personalPlan,
                style: _sectionTitleStyle(context),
              ),
              if (plan != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    plan.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: _sectionTitleStyle(context),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (value.isLoading && info == null)
            const _PlanStatus(child: CircularProgressIndicator())
          else if (value.hasError && info == null)
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
          else if (info == null || plan == null)
            _PlanStatus(
              child: Text(
                context.appLocalizations.personalNoActivePlan,
                textAlign: TextAlign.center,
              ),
            )
          else
            _PlanDetails(info: info),
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
            const SizedBox(height: 12),
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

class _OrdersSection extends StatelessWidget {
  const _OrdersSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: _profileCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.appLocalizations.personalOrders,
            style: _sectionTitleStyle(context),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
              final twoColumns = constraints.maxWidth >= 300 * scale;
              final items = [
                _OrderItem(
                  asset: 'assets/images/personal/cart.svg',
                  label: context.appLocalizations.personalPendingPayment,
                ),
                _OrderItem(
                  asset: 'assets/images/personal/order_list.svg',
                  label: context.appLocalizations.personalAllOrders,
                ),
              ];
              if (!twoColumns) {
                return Column(
                  children: [
                    items.first,
                    const SizedBox(height: 12),
                    items.last,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: items.first),
                  const SizedBox(width: 20),
                  Expanded(child: items.last),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          SvgPicture.asset(asset, width: 28, height: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              softWrap: true,
              style: context.textTheme.bodyMedium,
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
    required this.loggingOut,
    required this.onChangePassword,
    required this.onOpenAbout,
    required this.onLogout,
  });

  final bool loggingOut;
  final VoidCallback onChangePassword;
  final VoidCallback onOpenAbout;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Material(
        color: context.tDesign.container,
        child: Column(
          children: [
            _MenuRow(
              label: context.appLocalizations.personalChangePassword,
              onTap: onChangePassword,
            ),
            const Divider(height: 0.5, indent: 16),
            _MenuRow(
              label: context.appLocalizations.personalAppVersion,
              value: globalState.packageInfo.version,
              onTap: onOpenAbout,
            ),
            const Divider(height: 0.5, indent: 16),
            _MenuRow(
              iconAsset: 'assets/images/personal/logout.svg',
              label: context.appLocalizations.personalLogout,
              destructive: true,
              loading: loggingOut,
              onTap: onLogout,
              showChevron: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    this.iconAsset,
    this.value,
    this.onTap,
    this.destructive = false,
    this.loading = false,
    this.showChevron = true,
  });

  final String? iconAsset;
  final String label;
  final String? value;
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
        constraints: const BoxConstraints(minHeight: 56),
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
              if (value != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
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
  return BoxDecoration(
    color: context.tDesign.container,
    borderRadius: BorderRadius.circular(9),
    boxShadow: [
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
