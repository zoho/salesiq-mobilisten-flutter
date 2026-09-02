import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../widgets/ui/ui.dart';

enum _MatcherKind { exact, prefix, suffix, pattern }

class _PathRule {
  final TextEditingController value;
  _MatcherKind kind;
  _PathRule({String value = '', this.kind = _MatcherKind.prefix})
      : value = TextEditingController(text: value);
  void dispose() => value.dispose();
}

/// Detail H — URI scheme builder. Mirrors the native `SalesIQUriScheme`
/// (scheme + hosts + path matchers) and applies it via `setAndroidUriScheme`.
class UriSchemeScreen extends StatefulWidget {
  const UriSchemeScreen({super.key});

  @override
  State<UriSchemeScreen> createState() => _UriSchemeScreenState();
}

class _UriSchemeScreenState extends State<UriSchemeScreen> {
  final _scheme = TextEditingController(text: 'myapp');
  final List<TextEditingController> _hosts = [
    TextEditingController(text: 'example.com'),
  ];
  final List<_PathRule> _paths = [
    _PathRule(value: '/orders', kind: _MatcherKind.prefix),
    _PathRule(value: '/support/faq', kind: _MatcherKind.exact),
  ];
  Object? _result;

  @override
  void dispose() {
    _scheme.dispose();
    for (final h in _hosts) {
      h.dispose();
    }
    for (final p in _paths) {
      p.dispose();
    }
    super.dispose();
  }

  void _addHost() => setState(() => _hosts.add(TextEditingController()));
  void _addRule() => setState(() => _paths.add(_PathRule()));

  void _cycleKind(_PathRule rule) {
    const order = _MatcherKind.values;
    setState(
        () => rule.kind = order[(order.indexOf(rule.kind) + 1) % order.length]);
  }

  String _kindLabel(_MatcherKind kind) => switch (kind) {
        _MatcherKind.exact => 'Exact',
        _MatcherKind.prefix => 'Prefix',
        _MatcherKind.suffix => 'Suffix',
        _MatcherKind.pattern => 'Pattern',
      };

  PathMatcher _matcher(_PathRule rule) {
    final pathValue = rule.value.text.trim();
    return switch (rule.kind) {
      _MatcherKind.exact => Exact(pathValue),
      _MatcherKind.prefix => Prefix(pathValue),
      _MatcherKind.suffix => Suffix(pathValue),
      _MatcherKind.pattern => Pattern(pathValue),
    };
  }

  void _apply() {
    final scheme = _scheme.text.trim();
    if (scheme.isEmpty) {
      showToast('Enter a scheme first', ToastTone.danger);
      return;
    }
    final hosts = _hosts
        .map((host) => host.text.trim())
        .where((host) => host.isNotEmpty)
        .toList();
    final rules =
        _paths.where((rule) => rule.value.text.trim().isNotEmpty).toList();
    // Build the deep-link rule set the SDK matches incoming URIs against.
    final uriScheme = SalesIQUriScheme(scheme)
      ..addHosts(hosts)
      ..addPaths(rules.map(_matcher).toList());
    // Register which app URIs the SDK should intercept and handle (Android).
    ZohoSalesIQ.setAndroidUriScheme(uriScheme);
    setState(() => _result = uriScheme.toMap());
    showToast('URI scheme applied', ToastTone.success);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'URI scheme',
      subtitle: 'setUriScheme(scheme, hosts, paths)',
      children: [
        Section(
          title: 'Scheme',
          child: AppCard(
            children: [
              Field(
                label: 'Scheme',
                controller: _scheme,
                placeholder: 'myapp',
                textCapitalization: TextCapitalization.none,
              ),
            ],
          ),
        ),
        Section(
          title: 'Hosts',
          child: AppCard(
            children: [
              for (var i = 0; i < _hosts.length; i++)
                Field(
                  label: i == 0 ? 'Host' : 'Host ${i + 1}',
                  controller: _hosts[i],
                  placeholder: 'example.com',
                  textCapitalization: TextCapitalization.none,
                ),
              ListRow(
                title: 'Add host',
                icon: AppIcon.plus,
                titleTone: RowTitleTone.brand,
                onTap: _addHost,
              ),
            ],
          ),
        ),
        Section(
          title: 'Path matchers',
          child: AppCard(
            children: [
              for (final rule in _paths)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Field(
                        label: 'Path',
                        controller: rule.value,
                        placeholder: '/orders',
                        textCapitalization: TextCapitalization.none,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _cycleKind(rule),
                        child: AppBadge(label: _kindLabel(rule.kind)),
                      ),
                    ),
                  ],
                ),
              ListRow(
                title: 'Add rule',
                subtitle: 'exact / prefix / suffix / pattern',
                icon: AppIcon.plus,
                titleTone: RowTitleTone.brand,
                onTap: _addRule,
              ),
            ],
          ),
        ),
        AppButton(
          title: 'Apply URI scheme',
          icon: AppIcon.globe,
          onPressed: _apply,
        ),
        if (_result != null) ResultBlock(label: 'Applied', data: _result),
      ],
    );
  }
}
