import 'package:flutter/material.dart';
import 'package:interest_book/Contact/ContactList.dart';
import 'package:interest_book/Home/CustomerList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = true;
  String? name;

  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';

  loadName() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      name = prefs.getString("name") ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    loadName();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _showSearchBar) {
        setState(() => _showSearchBar = false);
      } else if (_scrollController.offset <= 50 && !_showSearchBar) {
        setState(() => _showSearchBar = true);
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchBarColor = Colors.blueGrey[300];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: searchBarColor,
        title: Text(name != null ? "Welcome, $name" : "Welcome, User"),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: _showSearchBar ? 60 : 0),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CustomerList(
                scrollController: _scrollController,
                searchQuery: _searchQuery,
              ),
            ),
          ),
          if (_showSearchBar)
            Container(
              color: searchBarColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search customers...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ContactList(title: "Contact"),
            ),
          );
        },
        child: const Icon(Icons.phone),
      ),
    );
  }
}
