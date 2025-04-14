import 'package:flutter/material.dart';
import 'package:interest_book/Login&Signup/LoginScreen.dart';

import '../Api/SignupApi.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formkey = GlobalKey<FormState>();
  final RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool agreePersonalData = false;
  final emailcontroller = TextEditingController();
  final namecontroller = TextEditingController();
  final phncontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final confirmpasscontroller = TextEditingController();
  bool isSimplePassword = true;
  bool isConfirmPassword = true;
  String? simplepass;
  String? confirmpass;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var userSignup = signupApi();
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 600,
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Center(
                          child: Text(
                            "Create Your Account :)",
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            "Fill in the details below to create your account..",
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
                                  onChanged: (value) {
                                    setState(() {
                                      simplepass = value;
                                    });
                                  },
                                  obscureText: isSimplePassword,
                                  obscuringCharacter: '*',
                                  decoration: InputDecoration(
                                    label: const Text('Password'),
                                    hintText: 'Enter Password',
                                    prefixIcon: const Icon(Icons.password),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isSimplePassword = !isSimplePassword;
                                        });
                                      },
                                      icon: const Icon(Icons.remove_red_eye),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Field can't be empty";
                                    } else if (value.length < 5 ||
                                        value.length > 8) {
                                      return "Password length must be between 5 to 8 characters";
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: confirmpasscontroller,
                                  keyboardType: TextInputType.visiblePassword,
                                  onChanged: (value) {
                                    setState(() {
                                      confirmpass = value;
                                    });
                                  },
                                  obscureText: isConfirmPassword,
                                  obscuringCharacter: '*',
                                  decoration: InputDecoration(
                                    label: const Text('Confirm Password'),
                                    hintText: 'Enter Confirm Password',
                                    prefixIcon: const Icon(Icons.password),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isConfirmPassword =
                                              !isConfirmPassword;
                                        });
                                      },
                                      icon: const Icon(Icons.remove_red_eye),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Field can't be empty";
                                    } else if (value != simplepass) {
                                      return "Password does not match";
                                    }
                                    return null;
                                  },
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: agreePersonalData,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          agreePersonalData = value!;
                                        });
                                      },
                                      activeColor: const Color(0xFF416FDF),
                                    ),
                                    const Text(
                                      'I agree to the processing of ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const Text(
                                      'Personal data',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF416FDF),
                                      ),
                                    ),
                                  ],
                                ),
                                isLoading
                                    ? SizedBox(
                                        width: double.infinity,
                                        height: 55,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          child:
                                              const CircularProgressIndicator(
                                            color: Color(0xFF416FDF),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 55,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (formkey.currentState!
                                                    .validate() &&
                                                agreePersonalData) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              formkey.currentState!.save();
                                              final userData =
                                                  await userSignup.userSignup(
                                                      namecontroller.text,
                                                      phncontroller.text,
                                                      emailcontroller.text,
                                                      confirmpass!);
                                              formkey.currentState!.reset();
                                              

                                              if (userData) {
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (BuildContext context) {
                                                      return const LoginScreen();
                                                    },
                                                  ),
                                                  (route) => false,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Signup Successfully'),
                                                  ),
                                                );
                                              }
                                            } else if (!agreePersonalData) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please agree to the processing of personal data',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Something Went Wrong'),
                                                ),
                                              );
                                            }
                                            setState(() {
                                              isLoading = false;
                                            });
                                          },
                                          child: const Text(
                                            'Sign up',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        decorationThickness: 2,
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
