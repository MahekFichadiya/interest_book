import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:interest_book/Api/RemoveLoan.dart';
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/DashboardScreen.dart';
import 'package:interest_book/Loan/DepositeAmount/InterestDashboard.dart';
import 'package:interest_book/Loan/EditLoan.dart';
import 'package:interest_book/Model/CustomerModel.dart';
import 'package:interest_book/Model/LoanDetail.dart';
import 'package:intl/intl.dart';

class GetLoanDetails extends StatefulWidget {
  final Loandetail? detail;
  final Customer customer;
  const GetLoanDetails(
      {super.key, required this.detail, required this.customer});

  @override
  State<GetLoanDetails> createState() => _GetLoanDetailsState();
}

class _GetLoanDetailsState extends State<GetLoanDetails> {
  String monthDifference(String? sDate, String? eDate) {
    if (sDate == null || eDate == null || eDate == "0000-00-00") {
      return "N/A";
    }

    DateTime startDate = DateTime.parse(sDate);
    DateTime endDate = DateTime.parse(eDate);

    int yearDiff = endDate.year - startDate.year;
    int monthDiff = endDate.month - startDate.month;

    return (yearDiff * 12 + monthDiff).toString();
  }

  String? formateDate(String Date) {
    try {
      DateTime parse = DateTime.parse(Date);
      return DateFormat('dd-MM-yyyy hh:mm a').format(parse);
    } catch (e) {
      return Date;
    }
  }

  String? formateEndDate(String Date) {
    try {
      DateTime parse = DateTime.parse(Date);
      return DateFormat('dd-MM-yyyy').format(parse);
    } catch (e) {
      return Date;
    }
  }

  String formatAmount(double value) {
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entry Detail"),
        backgroundColor: Colors.blueGrey.shade300,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditLoan(
                    customer: widget.customer,
                    details: widget.detail!,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Do you want to sattle loan?"),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await RemoveLoan().remove(widget.detail!.loanId);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancle'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.delete,
              size: 27,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 20),
              child: Text(
                "${widget.customer.custName} Took",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "₹${widget.detail?.amount}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.red,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "On ${formateDate(widget.detail!.startDate) ?? 'N/A'}", // Handle null case
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "Remaining Balance: ₹${widget.detail?.updatedAmount}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Deposit Amount",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "₹0",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Return Date",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    formateEndDate(widget.detail!.endDate == "0000-00-00"
                            ? "N/A"
                            : widget.detail!.endDate) ??
                        'N/A', // Handle null case
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Interest",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "₹${formatAmount(double.parse(widget.detail!.totalInterest))}",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Months",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    monthDifference(
                      widget.detail?.startDate,
                      widget.detail?.endDate,
                    ),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rate",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "${widget.detail!.rate}%",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Note",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    widget.detail!.note,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Deposite Interest",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "₹0",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Image",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  widget.detail!.image.isEmpty
                      ? const Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey)
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    showImage(detail: widget.detail),
                              ),
                            );
                            print(
                                "${UrlConstant.baseUrl}${widget.detail!.image}");
                            print(widget.detail!.image);
                          },
                          child: Image.network(
                            "${UrlConstant.showImage}/${widget.detail!.image}",
                            height: 50,
                            width: 50,
                            errorBuilder: (context, error, stackTrace) {
                              // Show a placeholder with tooltip if image fails to load
                              return Tooltip(
                                message: "Image could not be loaded",
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Depositeinterest(
                        detail: widget.detail,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Deposite Amount",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class showImage extends StatelessWidget {
  final Loandetail? detail;
  const showImage({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Center(
        child: detail!.image.isEmpty
            ? const Icon(Icons.image_not_supported,
                size: 50, color: Colors.grey)
            : GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => showImage(detail: detail),
                    ),
                  );
                  print("${UrlConstant.baseUrl}/${detail!.image}");
                  print(detail!.image);
                },
                child: Image.network(
                  "${UrlConstant.showImage}/${detail!.image}",
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.red,
                          ),
                          Text(
                            "Somthing went wrong...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
