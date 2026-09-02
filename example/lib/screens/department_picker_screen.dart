import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../theme/theme.dart';
import '../widgets/ui/ui.dart';

/// Detail E — department picker. `getDepartments` feeds a tap-to-select list;
/// selecting a row records the chosen name and pops with it.
/// Mirrors the v3 mockup "Department" picker.
class DepartmentPickerScreen extends StatefulWidget {
  /// The currently selected department name, highlighted on open.
  final String? selected;

  const DepartmentPickerScreen({super.key, this.selected});

  @override
  State<DepartmentPickerScreen> createState() => _DepartmentPickerScreenState();
}

class _DepartmentPickerScreenState extends State<DepartmentPickerScreen> {
  List<SalesIQDepartment> _departments = [];
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
      // Fetch the chat departments configured in the SalesIQ portal.
      final departments = await ZohoSalesIQ.conversation.getDepartments();
      if (!mounted) return;
      setState(() {
        _departments = departments;
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

  void _select(SalesIQDepartment department) {
    // Record the chosen department; new chats are routed to it via the
    // `departmentName` argument of ZohoSalesIQ.chat.start(...).
    showToast('Routing new chats to ${department.name}', ToastTone.success);
    Navigator.of(context).pop(department.name);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Department',
      subtitle: 'Route new chats to…',
      children: [
        AppCard(
          children: stateRows(
            loading: _loading,
            error: _error,
            empty: _departments.isEmpty,
            onRetry: _load,
            skeletonRows: 4,
            emptyIcon: AppIcon.department,
            emptyTitle: 'No departments',
            emptySubtitle: 'Sign in with real keys to list departments',
            children: _departments.map((department) {
              final isSelected = department.name == widget.selected;
              final available = department.available ?? false;
              return ListRow(
                title: department.name ?? 'Unknown',
                subtitle: available ? 'Online' : 'Offline',
                icon: AppIcon.department,
                tint: available ? IconTint.secondary : IconTint.primary,
                trailing: isSelected
                    ? Icon(AppIcons.of(AppIcon.check),
                        size: 18, color: context.colors.primary)
                    : null,
                onTap: () => _select(department),
              );
            }).toList(),
          ),
        ),
        const Section(
          footer:
              'getDepartments feeds the picker — tapping records the selection, '
              'no drill-in. New chats are routed via chat.start(departmentName).',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
