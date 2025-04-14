import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:interest_book/Contact/AddNewContact.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ContactList extends StatefulWidget {
  const ContactList({Key? key, required this.title});
  final String title;

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final formkey = GlobalKey<FormState>();
  List<Contact> contacts = [];
  List<Contact> searchResults = [];
  bool isLoading = true;
  late TextEditingController _searchController;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    getContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void getContacts() async {
    if (await Permission.contacts.isGranted) {
      fetchContacts();
    } else {
      await Permission.contacts.request();
    }
  }

  void fetchContacts() async {
    List<Contact> fetchedContacts = await ContactsService.getContacts();

    setState(() {
      contacts = fetchedContacts;
      isLoading = false;
    });
  }

  void performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    List<Contact> filteredContacts = contacts.where((contact) {
      final fullName =
          "${contact.givenName} ${contact.middleName} ${contact.familyName}"
              .toLowerCase();

      bool nameMatches = fullName.contains(query.toLowerCase());

      bool phoneNumberMatches = false;
      for (final phone in contact.phones ?? []) {
        if (phone.value != null && phone.value!.contains(query)) {
          phoneNumberMatches = true;
          break;
        }
      }

      return nameMatches || phoneNumberMatches;
    }).toList();

    setState(() {
      searchResults = filteredContacts;
    });
  }

  void resetContacts() {
    _searchController.clear();
    performSearch('');
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        resetContacts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[300],
        title: isSearching
            ? TextField(
                autofocus: true,
                controller: _searchController,
                onChanged: performSearch,
                decoration: InputDecoration(
                  hintText: "Search Contacts..",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                ),
                cursorColor: Colors.black26,
                style: const TextStyle(color: Colors.black),
              )
            : Text(
                widget.title,
              ),
        titleSpacing: -5,
        leading: isSearching
            ? IconButton(
                onPressed: toggleSearch,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return AddNewContact();
                  },
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          if (!isSearching)
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: toggleSearch,
            ),
          if (isSearching)
            IconButton(
              onPressed: resetContacts,
              icon: const Icon(
                Icons.clear,
                color: Colors.black,
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 144, 164, 174),
              ),
            )
          : ListView.builder(
              itemCount: _searchController.text.isEmpty
                  ? contacts.length
                  : searchResults.length,
              itemBuilder: (context, index) {
                final contact = _searchController.text.isEmpty
                    ? contacts[index]
                    : searchResults[index];
                final phones = contact.phones;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return AddNewContact(
                            custName: contact.displayName.toString(),
                            custPhn: phones![0].value.toString(),
                          );
                        },
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 8),
                    leading: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.blueGrey.shade300,
                      ),
                      child: Text(
                        contact.givenName != null &&
                                contact.givenName!.isNotEmpty
                            ? contact.givenName![0].toUpperCase()
                            : '',
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: phones != null && phones.isNotEmpty
                        ? Text(
                            phones[0].value ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : const SizedBox(),
                    horizontalTitleGap: 14,
                    trailing: IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () => _makeCall(contact),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Function to make a call
void _makeCall(Contact contact) async {
  final phone = contact.phones?.firstWhere((phone) => phone.value != null);
  if (phone != null) {
    final url = 'tel:${phone.value}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
