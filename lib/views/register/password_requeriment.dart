import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';

class PasswordRequirements extends StatefulWidget {
  final bool hasMinLength;
  final bool passwordsMatch;

  const PasswordRequirements({
    super.key,
    required this.hasMinLength,
    required this.passwordsMatch,
  });

  @override
  State<PasswordRequirements> createState() => _PasswordRequirementsState();
}

class _PasswordRequirementsState extends State<PasswordRequirements> {
  @override
  void didUpdateWidget(covariant PasswordRequirements oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildRequirementRow(bool conditionMet, String text) {
    return Row(
      children: [
        Icon(
          conditionMet ? Icons.check_circle : Icons.cancel,
          color: conditionMet ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: getTextColor(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildRequirementRow(widget.hasMinLength, "Mínimo 8 caracteres"),
        _buildRequirementRow(widget.passwordsMatch, "Contraseñas coinciden"),
      ],
    );
  }
}

