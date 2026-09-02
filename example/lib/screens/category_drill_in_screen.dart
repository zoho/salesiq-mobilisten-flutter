import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../widgets/ui/ui.dart';
import 'resource_detail_screen.dart';

/// Detail — tapping a category or resource-department lists its resources
/// (getResources filtered by categoryId or departmentId). Mirrors v3 mockup.
class CategoryDrillInScreen extends StatefulWidget {
  final String title;
  final String? categoryId;
  final String? departmentId;

  const CategoryDrillInScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.departmentId,
  });

  @override
  State<CategoryDrillInScreen> createState() => _CategoryDrillInScreenState();
}

class _CategoryDrillInScreenState extends State<CategoryDrillInScreen> {
  List<Resource?> _resources = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Fetch articles filtered by the tapped category or department.
      final res = await ZohoSalesIQ.knowledgeBase.getResources(
        ResourceType.articles,
        parentCategoryId: widget.categoryId,
        departmentId: widget.departmentId,
      );
      if (!mounted) return;
      setState(() {
        _resources = res.resources;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: widget.title,
      subtitle: _loading ? 'Loading…' : '${_resources.length} articles',
      children: [
        AppCard(
          children: stateRows(
            loading: _loading,
            error: _error,
            empty: _resources.whereType<Resource>().isEmpty,
            onRetry: _load,
            skeletonRows: 5,
            emptyIcon: AppIcon.article,
            emptyTitle: 'No articles here',
            emptySubtitle: 'This category has no published articles',
            children: _resources
                .whereType<Resource>()
                .map((resource) => ListRow(
                      title: resource.title ?? 'Article',
                      subtitle: widget.title,
                      icon: AppIcon.article,
                      tint: IconTint.accent,
                      chevron: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'Article'),
                          builder: (_) => ResourceDetailScreen(
                            resourceId: resource.id ?? '',
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
