import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/LoanDocument.dart';

class LoanDocumentApi {
  
  // Get all documents for a specific loan
  Future<List<LoanDocument>> getLoanDocuments(String loanId, String userId) async {
    try {
      var url = Uri.parse('${UrlConstant.getLoanDocuments}?loanId=$loanId&userId=$userId');

      print("DEBUG API: Requesting URL: $url");

      var response = await http.get(url);

      print("DEBUG API: Response status: ${response.statusCode}");
      print("DEBUG API: Response body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print("DEBUG API: Parsed response data: $responseData");

        if (responseData['status'] == 'true') {
          List<LoanDocument> documents = [];
          var documentsData = responseData['documents'] ?? [];
          print("DEBUG API: Found ${documentsData.length} documents in response");

          for (var doc in documentsData) {
            print("DEBUG API: Processing document: $doc");
            documents.add(LoanDocument.fromJson(doc));
          }
          return documents;
        } else {
          print("DEBUG API: API returned status false: ${responseData['message']}");
          throw Exception(responseData['message'] ?? 'Failed to load documents');
        }
      } else {
        print("DEBUG API: HTTP Error ${response.statusCode}: ${response.body}");
        throw Exception('Failed to load documents: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR getting loan documents: $e");
      throw Exception('Error getting loan documents: $e');
    }
  }

  // Add a new document to a loan
  Future<LoanDocument?> addLoanDocument(String loanId, String userId, File document) async {
    try {
      var url = Uri.parse(UrlConstant.addLoanDocument);
      var request = http.MultipartRequest("POST", url);
      
      request.fields['loanId'] = loanId;
      request.fields['userId'] = userId;
      
      if (await document.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath("document", document.path),
        );
      } else {
        throw Exception('Document file does not exist');
      }
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      
      if (jsonData['status'] == 'true') {
        return LoanDocument.fromJson(jsonData['document']);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to add document');
      }
    } catch (e) {
      print("Error adding loan document: $e");
      throw Exception('Error adding loan document: $e');
    }
  }

  // Add multiple documents to a loan
  Future<List<LoanDocument>> addMultipleLoanDocuments(String loanId, String userId, List<File> documents) async {
    List<LoanDocument> addedDocuments = [];
    
    for (File document in documents) {
      try {
        LoanDocument? addedDoc = await addLoanDocument(loanId, userId, document);
        if (addedDoc != null) {
          addedDocuments.add(addedDoc);
        }
      } catch (e) {
        print("Error adding document ${document.path}: $e");
        // Continue with other documents even if one fails
      }
    }
    
    return addedDocuments;
  }

  // Delete a document
  Future<bool> deleteLoanDocument(String documentId, String userId) async {
    try {
      var url = Uri.parse(UrlConstant.deleteLoanDocument);
      var request = http.MultipartRequest("POST", url);
      
      request.fields['documentId'] = documentId;
      request.fields['userId'] = userId;
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      
      return jsonData['status'] == 'true';
    } catch (e) {
      print("Error deleting loan document: $e");
      return false;
    }
  }

  // Get document URL for display
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
