import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:needu/cloud_db.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/features/auth/auth_services.dart';
import 'package:needu/utilis/size_config.dart';

class EmergencyContacts extends StatefulWidget {
  const EmergencyContacts({super.key, this.toUpdateContacts = false});
  final bool toUpdateContacts;

  @override
  State<EmergencyContacts> createState() => _EmergencyContactsState();
}

class _EmergencyContactsState extends State<EmergencyContacts> {
  @override
  void initState() {
    super.initState();
    widget.toUpdateContacts
        ? CloudDB.fetchCloudContacts()
        : CloudDB.loadLocalContacts();
  }

  @override
  void dispose() {
    super.dispose();
    CloudDB.updateEmergencyContacts(thisUser!.emergencyContacts.value!);
  }

  @override
  Widget build(BuildContext context) {
    return a(context);
  }

  Widget a(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: thisUser!.emergencyContacts,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Emergency Contacts', style: SizeConfig.sectionTitle),

                widget.toUpdateContacts
                    ? IconButton(
                        onPressed: () {
                          {
                            late final nameController = TextEditingController();
                            late String fullPhoneNumber;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Add Emergency Contact'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AuthTextField(
                                        label: 'Name',
                                        hint: 'Enter name',
                                        icon: Icons.person_outline,
                                        tFController: nameController,
                                        validator: (name) => name != null
                                            ? null
                                            : "Enter Name Please",
                                      ),
                                      // IconButton(onPressed: (){}, icon: Icon(Icons.countertops)),
                                      // Phone field with flags
                                      SizedBox(
                                        height: SizeConfig.defaultHeight2,
                                      ),
                                      IntlPhoneField(
                                        showDropdownIcon: false,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.all(
                                            SizeConfig.paddingSmall,
                                          ),
                                        ),
                                        initialCountryCode:
                                            'IN', // default India
                                        onChanged: (phone) {
                                          fullPhoneNumber =
                                              phone.completeNumber;
                                          print(fullPhoneNumber); // +91 xxx
                                        },
                                      ),
                                      SizedBox(
                                        height: SizeConfig.defaultHeight2,
                                      ),
                                      authButton(
                                        text: 'Verify through Otp',
                                        onPressed: () async {
                                          var now = DateTime.now();

                                          final Map<String, dynamic> contacts =
                                              Map.of(
                                                thisUser!
                                                        .emergencyContacts
                                                        .value ??
                                                    {},
                                              );
                                          contacts['id_${now.day}${now.month}${now.year}${now.microsecondsSinceEpoch}'] =
                                              {'name': nameController.text, 'phone': fullPhoneNumber};
                                          thisUser!.emergencyContacts.value =
                                              contacts;
                                        },
                                      ),
                                      SizedBox(height: SizeConfig.blockHeight),
                                      Text(
                                        'Verification is necessary to smoothly trigger SOS services',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                        icon: Icon(Icons.add_circle_outline),
                      )
                    : const SizedBox.shrink(),
              ],
            ),

            Card(
              child:
                  thisUser!.emergencyContacts.value == null ||
                      thisUser!.emergencyContacts.value!.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(SizeConfig.screenHPadding),
                      child: Center(
                        child: Text(
                          'Add contacts',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: thisUser!.emergencyContacts.value!.length,
                      itemBuilder: (context, int index) {
                        final contact = thisUser!
                            .emergencyContacts
                            .value!
                            .entries
                            .elementAt(index)
                            .value;
                        print(thisUser!.emergencyContacts.value!.length);
                        return ListTile(
                          leading: Icon(
                            Icons.phone_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(contact['name'] ?? 'Unknown'),
                          subtitle: Text(contact['phone'] ?? 'No phone number'),
                          trailing: widget.toUpdateContacts
                              ? IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    final contacts = Map.of(
                                      thisUser!.emergencyContacts.value!,
                                    );
                                    contacts.remove(
                                      contacts.keys.elementAt(index),
                                    );
                                    thisUser!.emergencyContacts.value =
                                        contacts; // 🔥 this will notify
                                  },
                                  tooltip: 'Delete Contact',
                                )
                              : null,
                          contentPadding: EdgeInsets.only(
                            left: SizeConfig.paddingSmall,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
