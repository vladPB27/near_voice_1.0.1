import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  // const MyTextField({Key key}) : super(key: key);

  TextEditingController controller;
  String hint;
  bool isPassword;
  TextInputType inputType;

  MyTextField({
    this.hint,
    this.controller,
    this.inputType,
    this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            focusColor: Colors.green,
            focusedBorder : OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          contentPadding: EdgeInsets.all(10),
          hintStyle: TextStyle(
            color: Colors.grey
          ),
          hintText: hint,
          fillColor: Colors.transparent,
        ),
        obscureText: isPassword,
        keyboardType: inputType,
      ),
    );
  }
}
