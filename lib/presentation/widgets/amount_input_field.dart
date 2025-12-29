import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;
  final bool autofocus;

  const AmountInputField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          keyboardType: TextInputType.number,
          inputFormatters: [
            _ThousandsSeparatorInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: hintText ?? '0',
            helperText: helperText,
            prefixText: '\$ ',
            prefixStyle: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: Theme.of(context).textTheme.titleLarge,
          validator: validator,
          onChanged: onChanged != null ? (_) => onChanged!() : null,
        ),
      ],
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Solo permitir dígitos y comas
    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9,]'), '');

    // Remover comas para parsear el número
    final digitsOnly = cleanText.replaceAll(',', '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    // Formatear manualmente
    String numStr = number.toString();
    String result = '';

    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) {
        result += ',';
      }
      result += numStr[i];
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
