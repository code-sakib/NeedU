
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:needu/cloud_db.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/core/model_class.dart';
import 'package:needu/features/audio/emergency_contacts.dart';
import 'package:needu/features/auth/auth_services.dart';
import 'package:needu/utilis/sign_out.dart';
import 'package:needu/utilis/size_config.dart';
import 'package:needu/utilis/snackbar.dart';

class PhoneAuth2 extends StatelessWidget {
  PhoneAuth2({super.key});

  static String? fullPhoneNumber;
  static String? fullN;
  static bool showAccCre = true;

  @override
  Widget build(BuildContext context) {
    final codeController = TextEditingController();
    final phoneAuthKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    showAccCre
        ? {
            Utilis.showSnackBar('Account Created. Now setup is required'),
            showAccCre = false,
          }
        : null;

    return Scaffold(
      body: Form(
        key: phoneAuthKey,
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.screenHPadding),
          child: Column(
            children: [
              Text(
                addEC ? 'Add Emergency Contact' : 'Account Setup',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: SizeConfig.defaultHeight2),

              // Name
              AuthTextField(
                label: 'Name *',
                hint: 'Your name please',
                icon: Icons.person,
                tFController: nameController,
                validator: (name) => name != null ? null : "Enter name please.",
              ),

              SizedBox(height: SizeConfig.defaultHeight2),

              // Phone
              IntlPhoneField(
                showDropdownIcon: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.all(SizeConfig.paddingSmall),
                  hintText: 'Required to send SOS',
                ),
                initialCountryCode: 'IN', // default India
                onChanged: (phone) {
                  fullPhoneNumber = phone.completeNumber;
                },
              ),
              SizedBox(height: SizeConfig.defaultHeight2),

              // Send OTP
              authButton(
                text: 'Send OTP',
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      fullPhoneNumber != null) {
                    fullN = nameController.text;
                    CloudDB.otpSending(fullPhoneNumber!, context);
                  } else {
                    Utilis.showSnackBar(
                      'Please enter required details',
                      isErr: true,
                    );
                  }
                },
              ),

              // OTP Input + Verify
              AuthTextField(
                tFController: codeController,
                label: 'OTP verification',
                hint: 'Enter OTP',
                icon: Icons.key,
              ),

              SizedBox(height: SizeConfig.defaultHeight2),
              authButton(
                text: 'Verify OTP',
                onPressed: () async {
                  if (codeController.text.isEmpty) {
                    Utilis.showSnackBar('Field is blank..', isErr: true);
                  } else {
                    await CloudDB.otpVerifying(codeController.text).then((
                      v,
                    ) async {
                      if (!addEC) {
                        if (v) {
                          thisUser = CurrentUser(auth.currentUser);
                          thisUser?.phoneNumber = fullPhoneNumber;
                          thisUser?.name = fullN;
                          await CloudDB.isNewUser();
                        }
                        context.go('/sos_page');
                      } else {
                        if (v) {
                          var now = DateTime.now();

                          final Map<String, dynamic> contacts = Map.of(
                            thisUser?.emergencyContacts.value ?? {},
                          );

                          final newKey =
                              'id_${now.day}${now.month}${now.year}${now.microsecondsSinceEpoch}';

                          contacts[newKey] = {
                            'name': fullN ?? 'Unknown',
                            'phone': fullPhoneNumber ?? 'N/A',
                          };

                          thisUser?.emergencyContacts.value = contacts;
                          CloudDB.updateEmergencyContacts(contacts);
                          addEC = false;
                          Utilis.showSnackBar('Emergency contact added Successfully');
                          context.pop();
                        }
                      }
                    });
                  }
                },
              ),

              SizedBox(height: SizeConfig.defaultHeight1),

              signOutButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
