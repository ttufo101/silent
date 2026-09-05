import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class DashboardAnnouncement {
  const DashboardAnnouncement({required this.content});

  final String content;
}

/// 公告接口接入后只需替换此 Provider 的数据来源。
final dashboardAnnouncementProvider = Provider<DashboardAnnouncement?>((ref) {
  return null;
});

class DashboardAnnouncementBar extends StatelessWidget {
  const DashboardAnnouncementBar({required this.announcement, super.key});

  final DashboardAnnouncement announcement;

  void _showDetail(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isChinese ? '公告' : 'Announcement'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 420),
          child: SingleChildScrollView(
            child: SelectableText(announcement.content),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: announcement.content,
      child: Material(
        color: context.colorScheme.primaryContainer.withValues(alpha: 0.92),
        child: InkWell(
          onTap: () => _showDetail(context),
          child: SizedBox(
            height: 28,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 17,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(child: _MarqueeText(text: announcement.content)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarqueeText extends StatefulWidget {
  const _MarqueeText({required this.text});

  final String text;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _distance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _distance = 0;
  }

  void _configure(double distance, bool animate) {
    if ((_distance - distance).abs() < 0.5 &&
        _controller.isAnimating == animate) {
      return;
    }
    _distance = distance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!animate || distance <= 0) {
        _controller.stop();
        _controller.value = 0;
        return;
      }
      _controller.duration = Duration(
        milliseconds: ((distance / 32) * 1000)
            .round()
            .clamp(3500, 18000)
            .toInt(),
      );
      _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onPrimaryContainer,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout();
        final overflow = painter.width > constraints.maxWidth;
        const gap = 36.0;
        final distance = painter.width + gap;
        _configure(distance, overflow && !reduceMotion);
        if (!overflow || reduceMotion) {
          return Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
        }
        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(-_controller.value * distance, 0),
              child: child,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.text, maxLines: 1, style: style),
                const SizedBox(width: gap),
                Text(widget.text, maxLines: 1, style: style),
              ],
            ),
          ),
        );
      },
    );
  }
}
