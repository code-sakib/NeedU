import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:needu/utilis/size_config.dart';

Widget phonePkg(TextEditingController pController) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  return Form(
    key: _formKey,
    child: IntlPhoneField(
      controller: pController,
      showDropdownIcon: false,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.all(SizeConfig.paddingSmall),
        hint: Text('Required to send SOS'),
      ),
      initialCountryCode: 'IN', // default India
      onChanged: (phone) {
        pController.text = phone.completeNumber;
      },
    ),
  );
}
