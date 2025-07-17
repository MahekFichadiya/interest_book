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
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenHeight < 700;
    final isTablet = screenWidth > 600;

    // Responsive dimensions
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final searchFontSize = isSmallScreen ? 14.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[300],
        toolbarHeight: isSmallScreen ? 50 : 56,
        title: isSearching
            ? TextField(
                autofocus: true,
                controller: _searchController,
                onChanged: performSearch,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: searchFontSize,
                ),
                decoration: InputDecoration(
                  hintText: "Search Contacts..",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.5),
                    fontSize: searchFontSize,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                ),
                cursorColor: Colors.black26,
              )
            : Text(
                widget.title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
        titleSpacing: isSmallScreen ? -8 : -5,
        leading: IconButton(
          onPressed: isSearching ? toggleSearch : () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: iconSize,
          ),
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
            icon: Icon(
              Icons.edit,
              size: iconSize,
            ),
          ),
          if (!isSearching)
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black,
                size: iconSize,
              ),
              onPressed: toggleSearch,
            ),
          if (isSearching)
            IconButton(
              onPressed: resetContacts,
              icon: Icon(
                Icons.clear,
                color: Colors.black,
                size: iconSize,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : contacts.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                      child: Text(
                        'No contacts found',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.blueGrey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _searchController.text.isEmpty ? contacts.length : searchResults.length,
                    itemBuilder: (context, index) {
                      final contact = _searchController.text.isEmpty
                          ? contacts[index]
                          : searchResults[index];

                      // Responsive dimensions for list items
                      final avatarRadius = isSmallScreen ? 20.0 : 25.0;
                      final titleFontSize = isSmallScreen ? 14.0 : 15.0;
                      final subtitleFontSize = isSmallScreen ? 11.0 : 12.0;
                      final avatarTextSize = isSmallScreen ? 16.0 : 20.0;

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
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 8,
                            vertical: isSmallScreen ? 2 : 4,
                          ),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 20 : 16,
                              vertical: isSmallScreen ? 4 : 8,
                            ),
                            leading: CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: Colors.blueGrey[300],
                              child: Text(
                                contact.displayName.isNotEmpty
                                    ? contact.displayName[0].toUpperCase()
                                    : '',
                                style: TextStyle(
                                  fontSize: avatarTextSize,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              contact.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: contact.phones.isNotEmpty
                                ? Text(
                                    contact.phones[0].number,
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                      color: Colors.blueGrey[600],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                : null,
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: isSmallScreen ? 14 : 16,
                              color: Colors.blueGrey[400],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
