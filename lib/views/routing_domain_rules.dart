import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RoutingDomainType { proxy, direct }

class RoutingDomainRulesView extends ConsumerStatefulWidget {
  const RoutingDomainRulesView({super.key, required this.type});

  final RoutingDomainType type;

  @override
  ConsumerState<RoutingDomainRulesView> createState() =>
      _RoutingDomainRulesViewState();
}

class _RoutingDomainRulesViewState
    extends ConsumerState<RoutingDomainRulesView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorText;

  String get _target => widget.type == RoutingDomainType.proxy
      ? RuleAction.MATCH.value
      : RuleTarget.DIRECT.name;

  String _normalize(String value) {
    var domain = value.trim().toLowerCase();
    if (domain.startsWith('*.')) domain = domain.substring(2);
    if (domain.startsWith('.')) domain = domain.substring(1);
    while (domain.endsWith('.')) {
      domain = domain.substring(0, domain.length - 1);
    }
    return domain;
  }

  bool _isValidDomain(String value) {
    if (value.isEmpty || value.length > 253) return false;
    if (value.contains(RegExp(r'[:/@\\\s]'))) return false;
    final labels = value.split('.');
    return labels.every(
      (label) =>
          label.isNotEmpty &&
          label.length <= 63 &&
          RegExp(r'^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$').hasMatch(label),
    );
  }

  bool _isManagedDomainRule(Rule rule) {
    return rule.ruleAction == RuleAction.DOMAIN_SUFFIX &&
        {
          RuleAction.MATCH.value,
          RuleTarget.DIRECT.name,
        }.contains(rule.ruleTarget?.toUpperCase());
  }

  void _addDomain(List<Rule> allRules) {
    final domain = _normalize(_controller.text);
    if (!_isValidDomain(domain)) {
      setState(() => _errorText = context.appLocalizations.domainInvalid);
      _focusNode.requestFocus();
      return;
    }
    final existing = allRules
        .where(_isManagedDomainRule)
        .firstWhereOrNull((rule) => _normalize(rule.content ?? '') == domain);
    if (existing != null) {
      final sameTarget = existing.ruleTarget?.toUpperCase() == _target;
      setState(
        () => _errorText = sameTarget
            ? context.appLocalizations.domainDuplicate
            : context.appLocalizations.domainConflict,
      );
      _focusNode.requestFocus();
      return;
    }
    ref
        .read(globalRulesProvider.notifier)
        .put(
          Rule(
            id: snowflake.id,
            ruleAction: RuleAction.DOMAIN_SUFFIX,
            content: domain,
            ruleTarget: _target,
          ),
        );
    _controller.clear();
    setState(() => _errorText = null);
    context.showNotifier(context.appLocalizations.domainSavedReconnect);
    _focusNode.requestFocus();
  }

  void _deleteDomain(Rule rule) {
    ref.read(globalRulesProvider.notifier).delAll([rule.id]);
    context.showNotifier(context.appLocalizations.domainSavedReconnect);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRules = ref.watch(globalRulesProvider).value ?? const <Rule>[];
    final rules = allRules
        .where(
          (rule) =>
              rule.ruleAction == RuleAction.DOMAIN_SUFFIX &&
              rule.ruleTarget?.toUpperCase() == _target,
        )
        .toList(growable: false);
    final title = widget.type == RoutingDomainType.proxy
        ? context.appLocalizations.customProxyDomains
        : context.appLocalizations.customDirectDomains;
    final help = widget.type == RoutingDomainType.proxy
        ? context.appLocalizations.proxyDomainHelp
        : context.appLocalizations.directDomainHelp;
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 600;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                desktop ? 24 : 16,
                desktop ? 24 : 16,
                desktop ? 24 : 16,
                32,
              ),
              children: [
                Material(
                  color: context.tDesign.container,
                  borderRadius: BorderRadius.circular(desktop ? 9 : 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flex(
                          direction: desktop ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (desktop)
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  decoration: InputDecoration(
                                    hintText: context
                                        .appLocalizations
                                        .domainInputHint,
                                    errorText: _errorText,
                                  ),
                                  onChanged: (_) {
                                    if (_errorText != null) {
                                      setState(() => _errorText = null);
                                    }
                                  },
                                  onSubmitted: (_) => _addDomain(allRules),
                                ),
                              )
                            else
                              TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                autocorrect: false,
                                enableSuggestions: false,
                                decoration: InputDecoration(
                                  hintText:
                                      context.appLocalizations.domainInputHint,
                                  errorText: _errorText,
                                ),
                                onChanged: (_) {
                                  if (_errorText != null) {
                                    setState(() => _errorText = null);
                                  }
                                },
                                onSubmitted: (_) => _addDomain(allRules),
                              ),
                            SizedBox(
                              width: desktop ? 12 : 0,
                              height: desktop ? 0 : 12,
                            ),
                            SizedBox(
                              width: desktop ? null : double.infinity,
                              height: desktop ? 40 : 52,
                              child: FilledButton.icon(
                                onPressed: () => _addDomain(allRules),
                                icon: const Icon(Icons.add, size: 20),
                                label: Text(context.appLocalizations.addDomain),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                help,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (rules.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        context.appLocalizations.noCustomDomains,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  Material(
                    color: context.tDesign.container,
                    borderRadius: BorderRadius.circular(desktop ? 9 : 12),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: rules
                          .map<Widget>(
                            (rule) => ListItem(
                              leading: const Icon(Icons.language_outlined),
                              title: Text(rule.content ?? ''),
                              subtitle: Text(rule.rawValue),
                              trailing: IconButton(
                                tooltip: context.appLocalizations.delete,
                                onPressed: () => _deleteDomain(rule),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: context.colorScheme.error,
                                ),
                              ),
                            ),
                          )
                          .separated(
                            Divider(
                              height: 0,
                              color: context.tDesign.componentStroke,
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    return CommonScaffold(title: title, body: content);
  }
}
