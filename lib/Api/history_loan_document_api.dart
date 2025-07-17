import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/LoanDocument.dart';

class HistoryLoanDocumentApi {
  
  // Get all documents for a specific history loan
  Future<List<LoanDocument>> getHistoryLoanDocuments(String loanId, String userId) async {
    try {
      var url = Uri.parse('${UrlConstant.getHistoryLoanDocuments}?loanId=$loanId&userId=$userId');

      print("DEBUG API: Requesting history documents URL: $url");

      var response = await http.get(url);

      print("DEBUG API: History documents response status: ${response.statusCode}");
      print("DEBUG API: History documents response body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        
        print("DEBUG API: Parsed history documents response data: $responseData");

        if (responseData['status'] == 'true') {
          List<LoanDocument> documents = [];

          // Add loan image if it exists
          if (responseData['loanImage'] != null) {
            print("DEBUG API: Found loan image in response");
            var loanImageData = responseData['loanImage'];

            LoanDocument loanImageDoc = LoanDocument(
              documentId: 0, // Special ID for loan image
              loanId: int.parse(loanImageData['loanId'].toString()),
              documentPath: loanImageData['documentPath'] ?? '',
              fileName: loanImageData['fileName'] ?? 'Loan Image',
              archivedDate: loanImageData['archivedDate'], // Will be null for loan images
            );

            documents.add(loanImageDoc);
            print("DEBUG API: Added loan image - Path: ${loanImageDoc.documentPath}");
          }

          // Add multiple documents
          if (responseData['documents'] != null) {
            print("DEBUG API: Found ${responseData['documents'].length} history documents in response");

            for (var docData in responseData['documents']) {
              print("DEBUG API: Processing history document: $docData");

              // Create LoanDocument with archivedDate for history documents
              LoanDocument document = LoanDocument(
                documentId: int.parse(docData['documentId'].toString()),
                loanId: int.parse(docData['loanId'].toString()),
                documentPath: docData['documentPath'] ?? '',
                fileName: docData['fileName'] ?? '',
                archivedDate: docData['archivedDate'], // This will be set for history documents
              );

              documents.add(document);
            }
          }

          print("DEBUG API: Loaded ${documents.length} total documents (including loan image if present)");
          for (var doc in documents) {
            print("DEBUG API: Document - ID: ${doc.documentId}, Path: ${doc.documentPath}, Archived: ${doc.archivedDate}");
          }

          return documents;
        } else {
          throw Exception('API Error: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        print("DEBUG API: HTTP Error ${response.statusCode}: ${response.body}");
        throw Exception('Failed to load history documents: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR getting history loan documents: $e");
      throw Exception('Error getting history loan documents: $e');
    }
  }

  // Get document URL for display (same as regular documents)
  static String getDocumentUrl(String documentPath) {
    if (documentPath.startsWith('http')) {
      return documentPath;
    } else {
      final String path = documentPath.startsWith('/') 
          ? documentPath.substring(1) 
          : documentPath;
      return "${UrlConstant.showImage}/$path";
    }
  }
}
