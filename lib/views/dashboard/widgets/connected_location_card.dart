import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/dashboard/country_map_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConnectedLocationMap extends StatefulWidget {
  const ConnectedLocationMap({
    required this.networkState,
    required this.showExitInfo,
    required this.onRetry,
    super.key,
  });

  final NetworkDetectionState networkState;
  final bool showExitInfo;
  final VoidCallback onRetry;

  @override
  State<ConnectedLocationMap> createState() => _ConnectedLocationMapState();
}

class _ConnectedLocationMapState extends State<ConnectedLocationMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulseController.stop();
      _pulseController.value = 0;
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ipInfo = widget.networkState.ipInfo;
    final location = CountryMapPosition.fromCode(ipInfo?.countryCode);
    final mapColor = context.colorScheme.onSurfaceVariant.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.09,
    );
    return RepaintBoundary(
      child: SizedBox(
        height: 232,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final hasLocation = ipInfo != null;
            final minimumMapWidth = constraints.maxHeight * 2;
            final mapWidth = hasLocation
                ? math.max(width * 2.05, minimumMapWidth)
                : math.max(width, minimumMapWidth);
            final mapHeight = mapWidth / 2;
            final x = (location.longitude + 180) / 360;
            final y = (90 - location.latitude) / 180;
            final markerY = constraints.maxHeight * 0.42;
            final left = (width / 2 - x * mapWidth)
                .clamp(width - mapWidth, 0.0)
                .toDouble();
            final top = (markerY - y * mapHeight)
                .clamp(constraints.maxHeight - mapHeight, 0.0)
                .toDouble();
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: left,
                  top: top,
                  width: mapWidth,
                  height: mapHeight,
                  child: SvgPicture.asset(
                    'assets/images/dashboard/world_map.svg',
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(mapColor, BlendMode.srcIn),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.tDesign.pageBackground.withValues(
                            alpha: 0.05,
                          ),
                          context.tDesign.pageBackground.withValues(
                            alpha: 0.22,
                          ),
                          context.tDesign.pageBackground.withValues(
                            alpha: 0.92,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.showExitInfo && hasLocation)
                  Positioned(
                    top: markerY - 46,
                    child: _PulseMarker(
                      animation: _pulseController,
                      color: context.tDesign.success,
                    ),
                  ),
                if (widget.showExitInfo)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: _ExitInfo(
                      state: widget.networkState,
                      location: location,
                      onRetry: widget.onRetry,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PulseMarker extends StatelessWidget {
  const _PulseMarker({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value;
        return SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 54 + 34 * value,
                height: 54 + 34 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.10 * (1 - value)),
                  border: Border.all(
                    color: color.withValues(alpha: 0.20 * (1 - value)),
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.16),
                  border: Border.all(color: color.withValues(alpha: 0.28)),
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExitInfo extends StatelessWidget {
  const _ExitInfo({
    required this.state,
    required this.location,
    required this.onRetry,
  });

  final NetworkDetectionState state;
  final CountryMapPosition location;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.ipInfo == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(context.appLocalizations.loading),
        ],
      );
    }
    final ipInfo = state.ipInfo;
    if (ipInfo == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.appLocalizations.networkException,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(context.appLocalizations.retry),
          ),
        ],
      );
    }
    final country = location.displayName(Localizations.localeOf(context));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(country, style: context.textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(
          'IP: ${ipInfo.ip}',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
