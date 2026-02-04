import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme.dart';

class PhoneInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? errorText;
  
  const PhoneInputWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  String _selectedCountryCode = '+233'; // Ghana default
  
  final List<Map<String, String>> _countryCodes = [
    {'code': '+233', 'country': 'Ghana', 'flag': '🇬🇭'},
    {'code': '+234', 'country': 'Nigeria', 'flag': '🇳🇬'},
    {'code': '+254', 'country': 'Kenya', 'flag': '🇰🇪'},
    {'code': '+27', 'country': 'South Africa', 'flag': '🇿🇦'},
    {'code': '+256', 'country': 'Uganda', 'flag': '🇺🇬'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code selector
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.dividerColor),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  items: _countryCodes.map((country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Row(
                        children: [
                          Text(
                            country['flag']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(country['code']!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCountryCode = value;
                      });
                      if (widget.onChanged != null) {
                        widget.onChanged!(
                          _selectedCountryCode + widget.controller.text
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            // Phone number input
            Expanded(
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: '241234567',
                  errorText: widget.errorText,
                  prefixIcon: const Icon(Icons.phone),
                ),
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(_selectedCountryCode + value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'We\'ll send you a verification code via SMS',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  String get fullPhoneNumber => _selectedCountryCode + widget.controller.text;
}
