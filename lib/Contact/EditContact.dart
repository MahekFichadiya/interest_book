import 'package:flutter/material.dart';
import 'package:interest_book/Model/CustomerModel.dart';

class EditContact extends StatefulWidget {
  final Customer? customer;
  const EditContact({super.key, this.customer});

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  final formKey = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilenumbercontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();

  loadData() {
    namecontroller.text = widget.customer!.custName;
    mobilenumbercontroller.text = widget.customer!.custPhn;
    addresscontroller.text = widget.customer!.custAddress!;
    setState(() {});
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
        title: Text('Edit Customer'),
        backgroundColor: Colors.blueGrey.shade300,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: namecontroller,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text("Name"),
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
                      controller: mobilenumbercontroller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text("Mobile Number"),
                        prefixIcon: Icon(Icons.phone_android),
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
                      controller: addresscontroller,
                      keyboardType: TextInputType.streetAddress,
                      decoration: const InputDecoration(
                        label: Text("Address (OPTIONAL)"),
                        prefixIcon: Icon(Icons.location_city_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: GestureDetector(
                  onTap: () {
                    if(formKey.currentState!.validate()){
                      formKey.currentState!.save();
                      formKey.currentState!.reset();
                          namecontroller.clear();
                          mobilenumbercontroller.clear();
                          addresscontroller.clear();
                    }
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                    ),
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
