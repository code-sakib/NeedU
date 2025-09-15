import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:needu/cloud_db.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/utilis/size_config.dart';
import 'package:needu/utilis/snackbar.dart';

bool addEC = false;

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
                          if (thisUser!.emergencyContacts.value!.length > 3) {
                           Utilis.showSnackBar('Only upto 3 contacts can be added for now..', isErr: true);
                          }
                          addEC = true;
                           context.push('/accountSetup');

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
                                        contacts; 
                                    CloudDB.updateEmergencyContacts(contacts);// 🔥 this will notify
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
