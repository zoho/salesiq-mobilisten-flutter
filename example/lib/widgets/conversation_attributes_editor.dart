import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten_core/salesiq_conversation_attributes.dart';
import 'package:salesiq_mobilisten_core/salesiq_department.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import 'ui/ui.dart';

/// A stable key for a department (id preferred, name fallback) — used for
/// selection state and list keys. Mirrors RN `departmentKey`.
String departmentKey(SalesIQDepartment department) =>
    department.id ?? department.name ?? '';

/// Backing state for one attribute set (global / start / trigger). Owns the
/// three text controllers plus the selected department keys, so each editor
/// instance keeps its own independent values.
///
/// Flutter counterpart of the RN `AttributesDraft` + `buildAttributes` pair.
/// The parent owns one controller per editor (like a [TextEditingController])
/// and calls [buildAttributes] to produce the SDK payload.
class ConversationAttributesController extends ChangeNotifier {
  /// Controller for the conversation display name field.
  final name = TextEditingController();

  /// Controller for the additional-info field.
  final additionalInfo = TextEditingController();

  /// Controller for the display-picture URL field.
  final displayPicture = TextEditingController();

  /// Selected department keys (id, or name when id is absent).
  final Set<String> _departmentKeys = <String>{};

  /// The currently selected department keys.
  Set<String> get departmentKeys => Set.unmodifiable(_departmentKeys);

  /// Replaces the selected department keys (called from the picker's Apply).
  void setDepartmentKeys(Set<String> keys) {
    _departmentKeys
      ..clear()
      ..addAll(keys);
    notifyListeners();
  }

  /// Builds a [SalesIQConversationAttributes] from the current state +
  /// [allDepartments], including only the fields the user actually filled in.
  /// Returns `null` when everything is empty, so callers can skip the SDK call.
  /// Selected departments are resolved back to full [SalesIQDepartment] objects
  /// (which carry `communicationMode`, required natively).
  SalesIQConversationAttributes? buildAttributes(
    List<SalesIQDepartment> allDepartments,
  ) {
    final trimmedName = name.text.trim();
    final trimmedInfo = additionalInfo.text.trim();
    final trimmedPicture = displayPicture.text.trim();
    final selected = allDepartments
        .where((d) => _departmentKeys.contains(departmentKey(d)))
        .toList();

    final hasAny = trimmedName.isNotEmpty ||
        trimmedInfo.isNotEmpty ||
        trimmedPicture.isNotEmpty ||
        selected.isNotEmpty;
    if (!hasAny) return null;

    return SalesIQConversationAttributes(
      name: trimmedName.isEmpty ? null : trimmedName,
      additionalInfo: trimmedInfo.isEmpty ? null : trimmedInfo,
      displayPicture: trimmedPicture.isEmpty ? null : trimmedPicture,
      departments: selected.isEmpty ? null : selected,
    );
  }

  @override
  void dispose() {
    name.dispose();
    additionalInfo.dispose();
    displayPicture.dispose();
    super.dispose();
  }
}

/// name / additionalInfo / displayPicture inputs + a **"Select department(s)"**
/// row that opens a modal checkbox list (Apply to commit, Cancel to discard).
///
/// The parent owns the [controller], so each attribute set (global
/// setAttributes, Chat.start, Chat.startWithTrigger) keeps its own values.
/// Mirrors the RN `ConversationAttributesEditor`.
class ConversationAttributesEditor extends StatefulWidget {
  /// Backing state (text fields + selected departments) for this editor.
  final ConversationAttributesController controller;

  /// The full department list offered in the "Select department(s)" picker.
  final List<SalesIQDepartment> departments;

  /// Creates an editor bound to [controller] and offering [departments].
  const ConversationAttributesEditor({
    super.key,
    required this.controller,
    required this.departments,
  });

  @override
  State<ConversationAttributesEditor> createState() =>
      _ConversationAttributesEditorState();
}

class _ConversationAttributesEditorState
    extends State<ConversationAttributesEditor> {
  @override
  void initState() {
    super.initState();
    // Rebuild the "Select department(s)" summary when the selection changes.
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  String get _summary {
    final selectedNames = widget.departments
        .where(
            (d) => widget.controller.departmentKeys.contains(departmentKey(d)))
        .map((d) => d.name ?? d.id ?? '')
        .toList();
    if (selectedNames.isEmpty) return 'None';
    if (selectedNames.length <= 2) return selectedNames.join(', ');
    return '${selectedNames.length} selected';
  }

  Future<void> _openPicker() async {
    // Working copy while the dialog is open, so "Cancel" discards and
    // "Apply" commits.
    final temp = <String>{...widget.controller.departmentKeys};
    final applied = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final c = dialogContext.colors;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const AppText('Select department(s)',
                  variant: AppType.subhead, weight: FontWeight.w600),
              contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              content: SizedBox(
                width: double.maxFinite,
                child: widget.departments.isEmpty
                    ? const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: AppText(
                          'No departments loaded yet (fetched after init).',
                          variant: AppType.caption,
                          tone: TextTone.secondary,
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AppText(
                                'Tick departments to route this conversation, then Apply.',
                                variant: AppType.caption,
                                tone: TextTone.secondary,
                              ),
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: widget.departments.map((department) {
                                  final key = departmentKey(department);
                                  final checked = temp.contains(key);
                                  final mode =
                                      department.communicationMode?.name;
                                  final availability =
                                      (department.available ?? false)
                                          ? 'online'
                                          : 'offline';
                                  return ListRow(
                                    title:
                                        department.name ?? department.id ?? key,
                                    subtitle: mode == null
                                        ? availability
                                        : '$mode · $availability',
                                    trailing: Icon(
                                      checked
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      size: 22,
                                      color:
                                          checked ? c.primary : c.textTertiary,
                                    ),
                                    onTap: () => setDialogState(() {
                                      if (checked) {
                                        temp.remove(key);
                                      } else {
                                        temp.add(key);
                                      }
                                    }),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (applied == true) {
      widget.controller.setDepartmentKeys(temp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Field(
          label: 'Name',
          controller: widget.controller.name,
          placeholder: 'Conversation display name',
        ),
        Field(
          label: 'Additional info',
          controller: widget.controller.additionalInfo,
          placeholder: 'Any extra info to display',
        ),
        Field(
          label: 'Display picture (URL)',
          controller: widget.controller.displayPicture,
          placeholder: 'https://…',
          keyboardType: TextInputType.url,
          textCapitalization: TextCapitalization.none,
        ),
        ListRow(
          title: 'Select department(s)',
          subtitle: 'Route the conversation',
          value: _summary,
          chevron: true,
          onTap: _openPicker,
        ),
      ],
    );
  }
}
