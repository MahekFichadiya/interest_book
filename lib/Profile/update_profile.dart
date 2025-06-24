import 'package:flutter/material.dart';
import 'package:interest_book/Api/update_profile_api.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final formkey = GlobalKey<FormState>();
  final RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phncontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  String? userId;

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    namecontroller.text = prefs.getString('name') ?? '';
    emailcontroller.text = prefs.getString('email') ?? '';
    phncontroller.text = prefs.getString('mobileNo') ?? '';
    userId = prefs.getString('userId') ?? '';
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  void dispose() {
    namecontroller.dispose();
    phncontroller.dispose();
    emailcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey[300],
        title: const Text("Update Profile"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: namecontroller,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text('Full Name'),
                        hintText: 'Enter Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          return;
                        }
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Field can't be empty";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: phncontroller,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        label: Text('Phone Number'),
                        hintText: 'Enter Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Field can't be empty";
                        } else if (value.length < 10) {
                          return "Your phone number is not proper";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: emailcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        label: Text("Email"),
                        prefixIcon: Icon(Icons.email),
                        hintText: "userName@gmail.com",
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          return;
                        } else if (!emailValidatorRegExp.hasMatch(value)) {
                          return;
                        }
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Field can't be emapty";
                        } else if (!emailValidatorRegExp.hasMatch(value)) {
                          return "Please enter valid Email";
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        onTap: () async {
                          bool updateProfile = await UpdateProfileAPI().update(
                            userId!,
                            namecontroller.text,
                            phncontroller.text,
                            emailcontroller.text,
                          );

                          if (updateProfile) {
                            // Update SharedPreferences and Provider
                            final provider = Provider.of<ProfileProvider>(
                                context,
                                listen: false);
                            await provider.updateProfile(
                              namecontroller.text,
                              phncontroller.text,
                              emailcontroller.text,
                            );

                            formkey.currentState!.reset();
                            namecontroller.clear();
                            phncontroller.clear();
                            emailcontroller.clear();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Profile Updated...")),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Something went wrong...")),
                            );
                          }
                        },
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                            border: Border.all(width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              "Update",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
