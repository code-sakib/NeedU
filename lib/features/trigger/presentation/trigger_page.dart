import 'dart:async';
import 'dart:convert';

import 'package:fj2/features/trigger/domain/contacts.dart';
import 'package:fj2/utilis&configs/globals.dart';
import 'package:fj2/utilis&configs/sizes.dart';
import 'package:fj2/utilis&configs/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class TriggerPage extends StatefulWidget {
  const TriggerPage({super.key});

  @override
  State<TriggerPage> createState() => _TriggerPageState();
}

class _TriggerPageState extends State<TriggerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          const Text(
            'NeedU',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: Give.height(context) / 1.3,
            width: Give.width(context),
            child: Card(
              child: ValueListenableBuilder(
                  valueListenable: toBuildSList,
                  builder: (context, child, widget) {
                    return ListView.builder(
                      itemCount: selectedContacts.length,
                      itemBuilder: (context, index) {
                        return ContactTile(
                            index: index, contactsToShow: selectedContacts);
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

class AddContacts extends StatefulWidget {
  const AddContacts({super.key});

  @override
  State<AddContacts> createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  List<Contact>? filteredContacts;
  TextEditingController searchController = TextEditingController();
  late Future fetchingData;
  Timer? timer;

  void filterContacts() {
    String query = searchController.text.toString();

    filteredContacts = allContacts
        .where((contact) =>
            contact.displayName?.toLowerCase().contains(query) ?? false)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    isLoaded();
    searchController.addListener(() => filterContacts());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  void isLoaded() {
    if (allContacts.isEmpty) {
      timer =
          Timer.periodic(const Duration(seconds: 2), (t) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: Give.height(context) / 2,
        width: Give.width(context) * 1.5,
        child: allContacts.isEmpty
            ? const CupertinoActivityIndicator()
            : Column(
                children: [
                  TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'search contacts to add',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      height: Give.height(context) / 2.5,
                      width: Give.width(context),
                      child: ListView.builder(
                        itemCount:
                            filteredContacts?.length ?? allContacts.length,
                        itemBuilder: (context, index) {
                          return ContactTile(
                            index: index,
                            contactsToShow: filteredContacts ?? allContacts,
                          );
                        },
                      ),
                    ),
                  )
                ],
              ));
  }
}

class ContactTile extends StatefulWidget {
  const ContactTile(
      {super.key, required this.index, required this.contactsToShow});
  final int index;
  final List<Contact> contactsToShow;

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  @override
  Widget build(BuildContext context) {
    Contact currentContact = widget.contactsToShow[widget.index];

    return currentContact.phones != null && currentContact.phones!.isNotEmpty
        ? ListTile(
            leading: CircleAvatar(
              backgroundImage: currentContact.avatar != null &&
                      currentContact.avatar!.isNotEmpty
                  ? MemoryImage(currentContact.avatar!)
                  : null,
              backgroundColor: const Color(0xFFACD0AD),
              child: currentContact.avatar == null ||
                      currentContact.avatar!.isEmpty
                  ? Text(currentContact
                      .initials()) // Display initial letter if no avatar
                  : null,
            ),
            title: Text(currentContact.displayName ?? 'Err name..'),
            subtitle: Text(currentContact.phones!.first.value ?? ""),
            trailing: Checkbox(
              value: selectedContacts.contains(currentContact),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    if (selectedContacts.length < 4) {
                      selectedContacts.add(currentContact);
                      showToast("contact added");
                    } else {
                      showToast("Max 4 contacts for now..");
                    }
                  } else {
                    selectedContacts.remove(currentContact);
                    showToast("contact removed");
                  }
                });
                toBuildSList.value += 1;

                _saveContacts();
              },
            ))
        : Container();
  }
}

_saveContacts() async {
  List<Map> encodedContacts = selectedContacts
      .map((contact) => (SelectedContacts().toJson(contact)))
      .toList();
  sharedPref.setString('selectedContacts', jsonEncode(encodedContacts));
}
