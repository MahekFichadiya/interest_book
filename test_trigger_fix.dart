import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // Test the trigger fix script
  const String baseUrl = "http://192.168.38.15/OmJavellerssHTML/";
  const String fixUrl = "${baseUrl}fix_loan_deletion_trigger.php";
  
  print("Testing trigger fix script at: $fixUrl");
  
  try {
    final response = await http.get(Uri.parse(fixUrl));
    
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      print("✅ Trigger fix script executed successfully!");
    } else {
      print("❌ Trigger fix script failed with status: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error calling trigger fix script: $e");
  }
}
