import 'package:flutter/material.dart';
import 'package:interest_book/Api/login_api.dart';
import 'package:interest_book/Login&Signup/SignupScreen.dart';
import 'package:interest_book/Login&Signup/SignupSuccess.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formkey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool ispassword = true;
  final RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool isloading = false;
  String? email, password;
  bool? login;

  userData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    login = prefs.getBool("login");
    email = prefs.getString("email");
    password = prefs.getString("password");
  }

  @override
  void initState() {
    userData();
    super.initState();
  }

  storeLoginData() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Do you want to save login data?"),
          actions: [
            TextButton(
              onPressed: () async {
                formkey.currentState!.save();
                setState(() {
                  isloading = true;
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("login", true);
                if (email == emailcontroller.text &&
                    password == passwordcontroller.text) {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const SignupSuccess();
                    },
                  ), (route) => false);
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Somthing went wrong"),
                    ),
                  );
                }
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () async {
                formkey.currentState!.save();
                setState(() {
                  isloading = true;
                });
                var userValue = await LoginAPI()
                    .userLogin(emailcontroller.text, passwordcontroller.text);
                if (userValue == true) {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const SignupSuccess();
                    },
                  ), (route) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Somthing went wrong"),
                    ),
                  );
                }
              },
              child: const Text("Cancle"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 70,
                    right: 15,
                    left: 15,
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          "Welcome Back :)",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          "Enter your credential for login to your account..",
                          style: TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Form(
                          key: formkey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: emailcontroller,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  label: Text("Email"),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    return;
                                  } else if (!emailValidatorRegExp
                                      .hasMatch(value)) {
                                    return;
                                  }
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Field can't be emapty";
                                  } else if (!emailValidatorRegExp
                                      .hasMatch(value)) {
                                    return "Please enter valid Email";
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: passwordcontroller,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: ispassword,
                                obscuringCharacter: "*",
                                decoration: InputDecoration(
                                  label: const Text("Password"),
                                  prefixIcon: const Icon(Icons.password),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        ispassword = !ispassword;
                                      });
                                    },
                                    icon: const Icon(Icons.remove_red_eye),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    return;
                                  } else if (value.length < 5 ||
                                      value.length > 8) {
                                    return;
                                  }
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Field can't be empty";
                                  } else if (value.length < 5 ||
                                      value.length > 8) {
                                    return "Password length should be 5 to 8 character";
                                  }
                                  return null;
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignupScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Signup",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationStyle:
                                              TextDecorationStyle.solid,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (formkey.currentState!.validate()) {
                                      if (login == true) {
                                        formkey.currentState!.save();
                                        setState(() {
                                          isloading = true;
                                        });
                                        if (email == emailcontroller.text &&
                                            password ==
                                                passwordcontroller.text) {
                                          formkey.currentState!.reset();
                                          emailcontroller.clear();
                                          passwordcontroller.clear();
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return const SignupSuccess();
                                              },
                                            ),
                                            (route) => false,
                                          );
                                        }
                                      } else {
                                        var userValue = await LoginAPI()
                                            .userLogin(emailcontroller.text,
                                                passwordcontroller.text);
                                        formkey.currentState!.reset();
                                        emailcontroller.clear();
                                        passwordcontroller.clear();
                                        if (userValue) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    "Do you want to save login data?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      prefs.setBool(
                                                          "login", true);
                                                      Navigator.of(context)
                                                          .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              SignupSuccess(),
                                                        ),
                                                        (route) => false,
                                                      );
                                                    },
                                                    child: const Text("Yes"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              SignupSuccess(),
                                                        ),
                                                        (route) => false,
                                                      );
                                                    },
                                                    child: const Text("Cancle"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text("Somthing Went Wrong"),
                                            ),
                                          );
                                        }
                                      }
                                      // storeLoginData();
                                      //   formkey.currentState!.save();
                                      //   setState(() {
                                      //     isloading = true;
                                      //   });
                                      //   var userValue = await LoginAPI()
                                      //       .userLogin(emailcontroller.text,
                                      //           passwordcontroller.text);
                                      //   if (userValue == true) {
                                      //     Navigator.of(context)
                                      //         .pushAndRemoveUntil(
                                      //             MaterialPageRoute(
                                      //       builder: (BuildContext context) {
                                      //         return const SignupSuccess();
                                      //       },
                                      //     ), (route) => false);
                                      //   } else {
                                      //     ScaffoldMessenger.of(context)
                                      //         .showSnackBar(
                                      //       const SnackBar(
                                      //         content:
                                      //             Text("Somthing went wrong"),
                                      //       ),
                                      //     );
                                      //   }
                                      // } else {
                                      //   ScaffoldMessenger.of(context)
                                      //       .showSnackBar(
                                      //     const SnackBar(
                                      //       content: Text("Somthing went wrong"),
                                      //     ),
                                      //   );
                                    }
                                    setState(() {
                                      isloading = false;
                                    });
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
                                        "Login",
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
              ),
              Positioned(
                top: -50,
                right: 130,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(width: 3, color: Colors.black),
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.person_outline_outlined,
                    size: 70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
