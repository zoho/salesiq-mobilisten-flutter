import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';

const List<Salutation> _salutations = [
  Salutation.mr,
  Salutation.ms,
  Salutation.mrs,
  Salutation.dr,
  Salutation.prof,
  Salutation.none,
];

String _salutationLabel(Salutation salutation) => salutation == Salutation.none
    ? 'None'
    : salutation.name[0].toUpperCase() + salutation.name.substring(1);

class _CustomInfo {
  final TextEditingController key;
  final TextEditingController value;
  _CustomInfo({String key = '', String value = ''})
      : key = TextEditingController(text: key),
        value = TextEditingController(text: value);
  void dispose() {
    key.dispose();
    value.dispose();
  }
}

/// Screen 04 — full profile via visitor.updateProfile; no deprecated
/// setVisitorName/setVisitorEmail/etc. Mirrors the RN `VisitorScreen`.
class VisitorScreen extends StatefulWidget {
  const VisitorScreen({super.key});

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen> {
  Salutation _salutation = Salutation.mr;
  final _firstName = TextEditingController(text: 'Jordan');
  final _lastName = TextEditingController(text: 'Rivera');
  final _email = TextEditingController(text: 'jordan@acme.com');
  final _phoneCode = TextEditingController();
  final _phone = TextEditingController();
  final _userId = TextEditingController();
  final _customAction = TextEditingController(text: 'promo_banner');
  final _locCity = TextEditingController();
  final _locState = TextEditingController();
  final _locCountry = TextEditingController();
  final _locZip = TextEditingController();
  final List<_CustomInfo> _customInfo = [
    _CustomInfo(key: 'plan', value: 'Enterprise'),
  ];
  Object? _result;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phoneCode.dispose();
    _phone.dispose();
    _userId.dispose();
    _customAction.dispose();
    _locCity.dispose();
    _locState.dispose();
    _locCountry.dispose();
    _locZip.dispose();
    for (final row in _customInfo) {
      row.dispose();
    }
    super.dispose();
  }

  void _performCustomAction() {
    if (_customAction.text.trim().isEmpty) {
      showToast('Enter an action name first', ToastTone.danger);
      return;
    }
    // Trigger a named tracking action for the visitor (configured in the portal).
    ZohoSalesIQ.visitor.performCustomAction(_customAction.text.trim());
    setState(() => _result = {
          'performCustomAction': _customAction.text.trim(),
        });
    showToast('Action performed', ToastTone.success);
  }

  void _cycleSalutation() {
    final index = _salutations.indexOf(_salutation);
    setState(
        () => _salutation = _salutations[(index + 1) % _salutations.length]);
  }

  void _removeCustomInfoRow(int i) {
    setState(() {
      _customInfo[i].dispose();
      _customInfo.removeAt(i);
    });
  }

  void _addCustomInfoRow() {
    setState(() => _customInfo.add(_CustomInfo()));
  }

  SIQVisitorLocation? _buildLocation() {
    final city = _locCity.text.trim();
    final state = _locState.text.trim();
    final country = _locCountry.text.trim();
    final zip = _locZip.text.trim();
    if (city.isEmpty && state.isEmpty && country.isEmpty && zip.isEmpty) {
      return null;
    }
    return SIQVisitorLocation()
      ..city = city.isEmpty ? null : city
      ..state = state.isEmpty ? null : state
      ..country = country.isEmpty ? null : country
      ..zipCode = zip.isEmpty ? null : zip;
  }

  SalesIQVisitorProfile _buildProfile() {
    final info = <String, String>{};
    for (final row in _customInfo) {
      final key = row.key.text.trim();
      if (key.isNotEmpty) info[key] = row.value.text;
    }
    return SalesIQVisitorProfile(
      location: _buildLocation(),
      salutation: _salutation,
      firstName: _firstName.text.isEmpty ? null : _firstName.text,
      lastName: _lastName.text.isEmpty ? null : _lastName.text,
      email: _email.text.isEmpty ? null : _email.text,
      // Country dialing code (e.g. "+1") and number are sent as separate fields.
      phone: _phone.text.isEmpty && _phoneCode.text.isEmpty
          ? null
          : SIQVisitorPhoneNumber(code: _phoneCode.text, number: _phone.text),
      userId: _userId.text.isEmpty ? null : _userId.text,
      customInfo: info.isEmpty ? null : info,
    );
  }

  void _updateProfile() {
    final profile = _buildProfile();
    // Push the visitor's details (name, email, custom info...) to SalesIQ.
    ZohoSalesIQ.visitor.updateProfile(profile);
    setState(() => _result = profile.toMap());
    showToast('Profile updated', ToastTone.success);
  }

  Future<void> _registerVisitor() async {
    final id = _userId.text.trim();
    if (id.isEmpty) {
      showToast('Add a user ID first', ToastTone.danger);
      return;
    }
    try {
      // Identify this visitor to SalesIQ with a stable unique id (signed-in user).
      final result = await ZohoSalesIQ.registerVisitor(id);
      setState(() => _result = {'registered': result ?? true});
      showToast('Visitor registered', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Registration failed', ToastTone.danger);
    }
  }

  Future<void> _unregisterVisitor() async {
    try {
      // Clear the identified visitor (e.g. on sign-out) so chats become anonymous.
      await ZohoSalesIQ.unregisterVisitor();
      setState(() => _result = {'unregistered': true});
      showToast('Visitor unregistered', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Unregister failed', ToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Visitor',
      subtitle: 'Profile, custom info, and registration',
      children: [
        Section(
          title: 'Profile',
          child: AppCard(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Field(label: 'First name', controller: _firstName),
                  ),
                  Container(width: 1, height: 60, color: context.hairline),
                  Expanded(
                    child: Field(label: 'Last name', controller: _lastName),
                  ),
                ],
              ),
              ListRow(
                title: 'Salutation',
                value: _salutationLabel(_salutation),
                chevron: true,
                onTap: _cycleSalutation,
              ),
              Field(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
              ),
              Field(
                label: 'Country code',
                controller: _phoneCode,
                placeholder: '+1',
                keyboardType: TextInputType.phone,
              ),
              Field(
                label: 'Phone',
                controller: _phone,
                placeholder: '(555) 000-0000',
                keyboardType: TextInputType.phone,
              ),
              Field(
                label: 'User ID',
                controller: _userId,
                placeholder: 'Unique visitor identifier',
                textCapitalization: TextCapitalization.none,
              ),
            ],
          ),
        ),
        Section(
          title: 'Custom info',
          child: AppCard(
            children: [
              for (var i = 0; i < _customInfo.length; i++)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Field(
                        label: i == 0 ? 'Key' : 'Key ${i + 1}',
                        controller: _customInfo[i].key,
                        placeholder: 'e.g. plan',
                        textCapitalization: TextCapitalization.none,
                      ),
                    ),
                    Container(width: 1, height: 60, color: context.hairline),
                    Expanded(
                      child: Field(
                        label: i == 0 ? 'Value' : 'Value ${i + 1}',
                        controller: _customInfo[i].value,
                        placeholder: 'e.g. Enterprise',
                      ),
                    ),
                    IconButton(
                      icon: Icon(AppIcons.of(AppIcon.close),
                          size: 20, color: context.danger),
                      onPressed: () => _removeCustomInfoRow(i),
                      tooltip: 'Remove field',
                      padding: const EdgeInsets.only(left: 6, top: 8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ListRow(
                title: 'Add key / value',
                icon: AppIcon.plus,
                tint: IconTint.primary,
                titleTone: RowTitleTone.brand,
                onTap: _addCustomInfoRow,
              ),
            ],
          ),
        ),
        Section(
          title: 'Location',
          footer: 'Optional secondary location sent with the visitor profile.',
          child: AppCard(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Field(label: 'City', controller: _locCity)),
                  Container(width: 1, height: 60, color: context.hairline),
                  Expanded(
                      child: Field(label: 'State', controller: _locState)),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child:
                          Field(label: 'Country', controller: _locCountry)),
                  Container(width: 1, height: 60, color: context.hairline),
                  Expanded(
                      child: Field(label: 'Zip code', controller: _locZip)),
                ],
              ),
            ],
          ),
        ),
        AppButton(title: 'Update profile', onPressed: _updateProfile),
        Row(
          children: [
            Expanded(
              child: AppButton(
                title: 'Register visitor',
                variant: ButtonVariant.secondary,
                onPressed: _registerVisitor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                title: 'Unregister',
                variant: ButtonVariant.secondary,
                onPressed: _unregisterVisitor,
              ),
            ),
          ],
        ),
        Section(
          title: 'Custom action',
          footer: 'Trigger a tracking action configured in the SalesIQ portal.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                Field(
                  label: 'Action name',
                  controller: _customAction,
                  placeholder: 'e.g. promo_banner',
                  textCapitalization: TextCapitalization.none,
                ),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Perform custom action',
                variant: ButtonVariant.secondary,
                onPressed: _performCustomAction,
              ),
            ],
          ),
        ),
        if (_result != null) ResultBlock(label: 'Last result', data: _result),
      ],
    );
  }
}

extension on BuildContext {
  Color get hairline => Theme.of(this).extension<AppColors>()!.hairline;
  Color get danger => Theme.of(this).extension<AppColors>()!.danger;
}
