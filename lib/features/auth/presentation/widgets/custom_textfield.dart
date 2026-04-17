import 'package:flutter/material.dart';

class CustonTextField extends StatefulWidget {
  const CustonTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    required this.textInputType,
    this.obscure = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final TextInputType textInputType;
  final bool obscure;

  @override
  State<CustonTextField> createState() => _CustonTextFieldState();
}

class _CustonTextFieldState extends State<CustonTextField> {
  @override
  void initState() {
    widget.focusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(
            widget.icon,
            color: widget.focusNode.hasFocus ? Colors.lightBlue : Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.lightBlue),
          ),
        ),
        autofillHints: [AutofillHints.email],
        keyboardType: widget.textInputType,
        obscureText: widget.obscure,
      ),
    );
  }
}
