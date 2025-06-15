import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Utils/amount_formatter.dart';

/// Custom TextFormField widget for amount input with real-time formatting
class AmountFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final bool showCurrencySymbol;
  final bool allowDecimals;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final InputDecoration? decoration;
  final TextStyle? style;
  final double? maxAmount;
  final bool required;

  const AmountFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.showCurrencySymbol = false,
    this.allowDecimals = true,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.decoration,
    this.style,
    this.maxAmount,
    this.required = true,
  }) : super(key: key);

  @override
  State<AmountFormField> createState() => _AmountFormFieldState();
}

class _AmountFormFieldState extends State<AmountFormField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  String? _validateAmount(String? value) {
    if (widget.required && (value == null || value.isEmpty)) {
      return 'Please enter ${widget.label.toLowerCase()}';
    }

    if (value != null && value.isNotEmpty) {
      // Get raw numeric value
      String rawValue = AmountFormatter.getRawValue(value);
      double? amount = double.tryParse(rawValue);
      
      if (amount == null) {
        return 'Please enter a valid amount';
      }
      
      if (amount <= 0) {
        return 'Amount must be greater than 0';
      }
      
      if (widget.maxAmount != null && amount > widget.maxAmount!) {
        return 'Amount cannot exceed ${AmountFormatter.formatCurrency(widget.maxAmount)}';
      }
    }

    // Call custom validator if provided
    if (widget.validator != null) {
      return widget.validator!(value);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          keyboardType: TextInputType.numberWithOptions(
            decimal: widget.allowDecimals,
            signed: false,
          ),
          inputFormatters: [
            AmountFormatter.getAmountInputFormatter(),
            if (!widget.allowDecimals)
              FilteringTextInputFormatter.deny(RegExp(r'\.')),
          ],
          style: widget.style ?? const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: widget.decoration ?? InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText ?? 'Enter ${widget.label.toLowerCase()}',
            prefixIcon: widget.prefixIcon != null 
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused ? Colors.blueGrey[600] : Colors.grey[600],
                  )
                : null,
            prefixText: widget.showCurrencySymbol ? '₹ ' : null,
            prefixStyle: TextStyle(
              color: _isFocused ? Colors.blueGrey[600] : Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueGrey[600]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: widget.enabled 
                ? (_isFocused ? Colors.blueGrey[50] : Colors.grey[50])
                : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: _validateAmount,
          onChanged: (value) {
            if (widget.onChanged != null) {
              // Pass the raw numeric value to onChanged callback
              String rawValue = AmountFormatter.getRawValue(value);
              widget.onChanged!(rawValue);
            }
          },
        ),
        if (_isFocused && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              'Amount: ${AmountFormatter.formatCurrency(AmountFormatter.getRawValue(widget.controller.text))}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Helper method to get raw amount value from AmountFormField controller
class AmountFormFieldHelper {
  /// Get the raw numeric value from the controller
  static String getRawAmount(TextEditingController controller) {
    return AmountFormatter.getRawValue(controller.text);
  }

  /// Get the formatted display value
  static String getFormattedAmount(TextEditingController controller) {
    String rawValue = getRawAmount(controller);
    if (rawValue.isEmpty) return '';
    return AmountFormatter.formatCurrency(rawValue);
  }

  /// Set amount value to controller with formatting
  static void setAmount(TextEditingController controller, dynamic amount) {
    if (amount == null) {
      controller.clear();
      return;
    }
    
    // Parse the amount
    double value = 0.0;
    if (amount is double) {
      value = amount;
    } else if (amount is int) {
      value = amount.toDouble();
    } else if (amount is String) {
      value = double.tryParse(amount.replaceAll(RegExp(r'[₹,\s]'), '')) ?? 0.0;
    }
    
    if (value == 0) {
      controller.clear();
      return;
    }
    
    // Set the formatted value
    controller.text = AmountFormatter.formatAmount(value);
  }
}
