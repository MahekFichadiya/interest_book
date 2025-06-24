import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:interest_book/Contact/AddNewContact.dart';

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
  if (await FlutterContacts.requestPermission()) {
    print('Permission granted');
    fetchContacts();
  } else {
    print('Permission denied');
    setState(() => isLoading = false);
  }
}


  void fetchContacts() async {
  List<Contact> fetchedContacts = await FlutterContacts.getContacts(withProperties: true);
  print('Fetched contacts: ${fetchedContacts.length}');
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
      final fullName = contact.displayName.toLowerCase();
      final phoneNumberMatches = contact.phones.any(
        (phone) => phone.number.contains(query),
      );

      return fullName.contains(query.toLowerCase()) || phoneNumberMatches;
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
      if (!isSearching) resetContacts();
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
                  hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
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
    ? const Center(child: CircularProgressIndicator())
    : contacts.isEmpty
        ? const Center(child: Text('No contacts found'))
        : ListView.builder(
            itemCount: _searchController.text.isEmpty ? contacts.length : searchResults.length,
            itemBuilder: (context, index) {
              final contact = _searchController.text.isEmpty
                  ? contacts[index]
                  : searchResults[index];
              return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddNewContact(
                        custName: contact.displayName,
                        custPhn: contact.phones.isNotEmpty
                            ? contact.phones[0].number
                            : '',
                      ),
                    ));
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey[300],
                      child: Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName[0].toUpperCase()
                            : '',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: contact.phones.isNotEmpty
                        ? Text(
                            contact.phones[0].number,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : const SizedBox(),
                    // trailing: IconButton(
                    //   icon: const Icon(Icons.phone),
                    //   onPressed: () => _makeCall(contact),
                    // ),
                  ),
                );
            },
          ),

    );
  }

  // void _makeCall(Contact contact) async {
  //   if (contact.phones.isNotEmpty) {
  //     final url = 'tel:${contact.phones[0].number}';
  //     if (await canLaunch(url)) {
  //       await launch(url);
  //     } else {
  //       throw 'Could not launch $url';
  //     }
  //   }
  // }
}
