import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../widgets/ui/ui.dart';

/// Detail — a single article fetched via getSingleResource(id). "Open article"
/// launches the SDK's built-in resource viewer. Mirrors the v3 mockup.
class ResourceDetailScreen extends StatefulWidget {
  final String resourceId;

  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  Resource? _resource;
  bool _loading = true;
  Object? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Fetch one article by id.
      final resource = await ZohoSalesIQ.knowledgeBase.getSingleResource(
        ResourceType.articles,
        widget.resourceId,
      );
      if (!mounted) return;
      setState(() {
        _resource = resource;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _result = {'error': e.toString()};
      });
    }
  }

  Future<void> _open() async {
    try {
      // Open this article in the SDK's built-in article viewer.
      final ok = await ZohoSalesIQ.knowledgeBase
          .open(ResourceType.articles, widget.resourceId);
      setState(() => _result = {'opened': ok, 'id': widget.resourceId});
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to open article', ToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resource = _resource;
    return ScreenScaffold(
      title: 'Article',
      subtitle: 'resourceId · ${widget.resourceId}',
      children: [
        AppCard(
          children: _loading
              ? const [ListRow(title: 'Loading article…', disabled: true)]
              : [
                  ListRow(
                    title: resource?.title ?? 'Article',
                    subtitle: resource?.category?.name ?? 'Knowledge base',
                    icon: AppIcon.article,
                    tint: IconTint.accent,
                  ),
                  ListRow(
                      title: 'Department',
                      value: resource?.departmentId ?? '—'),
                  ListRow(
                      title: 'Language',
                      value: resource?.language?.code ?? '—'),
                ],
        ),
        AppButton(
            title: 'Open article', icon: AppIcon.article, onPressed: _open),
        if (_result != null) ResultBlock(label: 'Last result', data: _result),
      ],
    );
  }
}
