import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';
import 'category_drill_in_screen.dart';
import 'resource_detail_screen.dart';

class _RecentArticle {
  final String id;
  final String title;
  final String category;
  const _RecentArticle(this.id, this.title, this.category);
}

const List<_RecentArticle> _recentlyViewed = [
  _RecentArticle('a1', 'Getting started with live chat', 'Onboarding'),
  _RecentArticle('a2', 'Setting up push notifications', 'Configuration'),
  _RecentArticle('a3', 'Routing chats to departments', 'Advanced'),
];

const _articles = ResourceType.articles;
// FAQs is pending the iOS native implementation. Uncomment when iOS supports it.
// const _faqs = ResourceType.faqs;

/// Screen 07 — browse, search, and drill into self-service articles,
/// categories, and departments. Mirrors the RN `KnowledgeBaseScreen`.
class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final _search = TextEditingController();
  final _resourceId = TextEditingController();
  final _recentCount = TextEditingController(text: '5');
  bool _showKnowledgeBase = true;
  bool _groupByCategory = true;
  bool _combineDepartments = false;
  List<Resource?> _searchResults = [];
  List<ResourceCategory> _categories = [];
  List<ResourceDepartment> _departments = [];
  Object? _result;

  @override
  void dispose() {
    _search.dispose();
    _resourceId.dispose();
    _recentCount.dispose();
    super.dispose();
  }

  void _toggleVisibility(bool value) {
    setState(() => _showKnowledgeBase = value);
    // Show or hide the Knowledge Base (articles) section in the SDK UI.
    ZohoSalesIQ.knowledgeBase.setVisibility(_articles, value);
  }

  void _toggleGrouping(bool value) {
    setState(() => _groupByCategory = value);
    // Group articles by category (vs. a flat list) in the SDK UI.
    ZohoSalesIQ.knowledgeBase.categorize(_articles, value);
  }

  void _toggleCombine(bool value) {
    setState(() => _combineDepartments = value);
    // Merge articles from all departments into one list (vs. per-department).
    ZohoSalesIQ.knowledgeBase.combineDepartments(_articles, value);
  }

  Future<void> _searchArticles() async {
    try {
      // Fetch a page of articles, optionally filtered by a search term.
      final res = await ZohoSalesIQ.knowledgeBase.getResources(
        _articles,
        searchKey: _search.text.trim().isEmpty ? null : _search.text.trim(),
        page: 1,
        limit: 25,
      );
      setState(() {
        _searchResults = res.resources;
        _result = {
          'query': _search.text.trim(),
          'count': res.resources.length,
          'moreDataAvailable': res.moreDataAvailable,
        };
      });
      showToast('Found ${res.resources.length} articles', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Search failed', ToastTone.danger);
    }
  }

  Future<void> _checkEnabled() async {
    try {
      // Check whether the articles resource type is enabled in the portal.
      final enabled = await ZohoSalesIQ.knowledgeBase.isEnabled(_articles);
      setState(() => _result = {'articlesEnabled': enabled});
      showToast(enabled ? 'Articles enabled' : 'Articles disabled');
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
    }
  }

  // FAQs is pending the iOS native implementation. Uncomment when iOS supports it.
  // Future<void> _checkFaqsEnabled() async {
  // try {
  // // The same KnowledgeBase APIs accept the FAQs resource type.
  // final enabled = await ZohoSalesIQ.knowledgeBase.isEnabled(_faqs);
  // final res = await ZohoSalesIQ.knowledgeBase.getResources(
  // _faqs,
  // page: 1,
  // limit: 25,
  // );
  // setState(() => _result = {
  // 'faqsEnabled': enabled,
  // 'faqCount': res.resources.length,
  // });
  // showToast('FAQs: ${res.resources.length}', ToastTone.success);
  // } catch (e) {
  // setState(() => _result = {'error': e.toString()});
  // showToast('FAQs fetch failed', ToastTone.danger);
  // }
  // }

  void _applyRecentCount() {
    final limit = int.tryParse(_recentCount.text.trim());
    if (limit == null) {
      showToast('Enter a number', ToastTone.danger);
      return;
    }
    // Set how many recently viewed articles the SDK keeps and shows.
    ZohoSalesIQ.knowledgeBase.setRecentlyViewedCount(limit);
    showToast('Recently-viewed count set to $limit', ToastTone.success);
  }

  Future<void> _fetchCategories() async {
    try {
      // Fetch the list of article categories from the portal.
      final categories =
          await ZohoSalesIQ.knowledgeBase.getCategories(_articles);
      setState(() {
        _categories = categories;
        _result = {'categories': categories.length};
      });
      showToast('Categories loaded', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to load categories', ToastTone.danger);
    }
  }

  Future<void> _fetchDepartments() async {
    try {
      // Fetch the list of departments that own knowledge base resources.
      final departments =
          await ZohoSalesIQ.knowledgeBase.getResourceDepartments();
      setState(() {
        _departments = departments;
        _result = {'departments': departments.length};
      });
      showToast('Departments loaded', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to load departments', ToastTone.danger);
    }
  }

  Future<void> _openArticle(String id) async {
    try {
      // Open a specific article in the SDK's article viewer, by its id.
      final ok = await ZohoSalesIQ.knowledgeBase.open(_articles, id);
      setState(() => _result = {'opened': ok, 'id': id});
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to open article', ToastTone.danger);
    }
  }

  void _openDetail(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'Article'),
        builder: (_) => ResourceDetailScreen(resourceId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ScreenScaffold(
      title: 'Knowledge Base',
      subtitle: 'Articles, categories, and departments',
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: c.border, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Icon(AppIcons.of(AppIcon.search),
                  size: 18, color: c.textTertiary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _search,
                  cursorColor: c.primary,
                  style: TextStyle(fontSize: 14.5, color: c.textPrimary),
                  onSubmitted: (_) => _searchArticles(),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Search articles',
                    hintStyle: TextStyle(fontSize: 14.5, color: c.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppButton(
          title: 'Search articles',
          variant: ButtonVariant.secondary,
          icon: AppIcon.search,
          onPressed: _searchArticles,
        ),
        if (_searchResults.isNotEmpty)
          Section(
            title: 'Results',
            child: AppCard(
              children: _searchResults
                  .whereType<Resource>()
                  .map((resource) => ListRow(
                        title: resource.title ?? 'Article',
                        subtitle: 'Tap to view details',
                        icon: AppIcon.article,
                        tint: IconTint.accent,
                        chevron: true,
                        onTap: () => _openDetail(resource.id ?? ''),
                      ))
                  .toList(),
            ),
          ),
        Section(
          title: 'Visibility & behavior',
          child: AppCard(
            children: [
              SwitchRow(
                title: 'Show knowledge base',
                value: _showKnowledgeBase,
                onChanged: _toggleVisibility,
              ),
              SwitchRow(
                title: 'Group by category',
                value: _groupByCategory,
                onChanged: _toggleGrouping,
              ),
              SwitchRow(
                title: 'Combine departments',
                value: _combineDepartments,
                onChanged: _toggleCombine,
              ),
              ListRow(
                title: 'Articles enabled?',
                value: 'Check',
                chevron: true,
                onTap: _checkEnabled,
              ),
              // FAQs is pending the iOS native implementation. Uncomment when iOS supports it.
              // ListRow(
              // title: 'FAQs enabled?',
              // value: 'Check',
              // chevron: true,
              // onTap: _checkFaqsEnabled,
              // ),
            ],
          ),
        ),
        Section(
          title: 'Recently viewed',
          footer: 'Set how many recently-viewed articles the SDK keeps.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                children: [
                  ..._recentlyViewed.map((article) => ListRow(
                        title: article.title,
                        subtitle: article.category,
                        icon: AppIcon.article,
                        tint: IconTint.accent,
                        chevron: true,
                        onTap: () => _openArticle(article.id),
                      )),
                  Field(
                      label: 'Recently-viewed count', controller: _recentCount),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                title: 'Apply count',
                variant: ButtonVariant.ghost,
                onPressed: _applyRecentCount,
              ),
            ],
          ),
        ),
        Section(
          title: 'Single resource',
          footer:
              'Fetch one article by ID (getSingleResource) and open detail.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                Field(
                  label: 'Resource ID',
                  controller: _resourceId,
                  placeholder: 'e.g. a1',
                  textCapitalization: TextCapitalization.none,
                ),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Open resource detail',
                variant: ButtonVariant.secondary,
                onPressed: () {
                  if (_resourceId.text.trim().isEmpty) {
                    showToast('Enter a resource ID', ToastTone.danger);
                    return;
                  }
                  _openDetail(_resourceId.text.trim());
                },
              ),
            ],
          ),
        ),
        AppButton(
          title: 'Fetch categories',
          variant: ButtonVariant.secondary,
          icon: AppIcon.knowledgeBase,
          onPressed: _fetchCategories,
        ),
        if (_categories.isNotEmpty)
          Section(
            title: 'Categories',
            child: AppCard(
              children: _categories
                  .map((cat) => ListRow(
                        title: cat.name ?? cat.id ?? 'Category',
                        icon: AppIcon.knowledgeBase,
                        tint: IconTint.primary,
                        chevron: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            settings:
                                RouteSettings(name: cat.name ?? 'Category'),
                            builder: (_) => CategoryDrillInScreen(
                              title: cat.name ?? 'Category',
                              categoryId: cat.id,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        AppButton(
          title: 'Fetch resource departments',
          variant: ButtonVariant.ghost,
          onPressed: _fetchDepartments,
        ),
        if (_departments.isNotEmpty)
          Section(
            title: 'Departments',
            child: AppCard(
              children: _departments
                  .map((dept) => ListRow(
                        title: dept.name ?? dept.id ?? 'Department',
                        icon: AppIcon.knowledgeBase,
                        tint: IconTint.secondary,
                        chevron: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            settings:
                                RouteSettings(name: dept.name ?? 'Department'),
                            builder: (_) => CategoryDrillInScreen(
                              title: dept.name ?? 'Department',
                              departmentId: dept.id,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        if (_result != null) ResultBlock(label: 'Last result', data: _result),
      ],
    );
  }
}
