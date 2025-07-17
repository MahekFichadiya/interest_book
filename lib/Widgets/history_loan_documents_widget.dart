import 'package:flutter/material.dart';
import 'package:interest_book/Api/history_loan_document_api.dart';
import 'package:interest_book/Model/LoanDocument.dart';
import 'package:interest_book/Widgets/loan_document_full_screen_viewer.dart';

class HistoryLoanDocumentsWidget extends StatefulWidget {
  final String loanId;
  final String userId;
  final String customerName;

  const HistoryLoanDocumentsWidget({
    Key? key,
    required this.loanId,
    required this.userId,
    required this.customerName,
  }) : super(key: key);

  @override
  State<HistoryLoanDocumentsWidget> createState() => _HistoryLoanDocumentsWidgetState();
}

class _HistoryLoanDocumentsWidgetState extends State<HistoryLoanDocumentsWidget> {
  List<LoanDocument> documents = [];
  bool isLoading = true;
  String? errorMessage;
  final HistoryLoanDocumentApi _api = HistoryLoanDocumentApi();

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print("DEBUG: Loading history documents for loanId: ${widget.loanId}, userId: ${widget.userId}");
      
      final loadedDocuments = await _api.getHistoryLoanDocuments(widget.loanId, widget.userId);
      
      setState(() {
        documents = loadedDocuments;
        isLoading = false;
      });

      print("DEBUG: Loaded ${documents.length} history documents");
    } catch (e) {
      print("ERROR loading history documents: $e");
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _showFullScreenDocument(LoanDocument document) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoanDocumentFullScreenViewer(
          document: document,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.blueGrey[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Loan Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isLoading && documents.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${documents.length}',
                      style: TextStyle(
                        color: Colors.blueGrey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading archived documents...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[300],
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load archived documents',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadDocuments,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[300],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else if (documents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No archived documents found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This settled loan has no archived documents',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];
                  final isLoanImage = document.documentId == 0; // Loan image has ID 0

                  return GestureDetector(
                    onTap: () => _showFullScreenDocument(document),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isLoanImage ? Colors.blue[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLoanImage ? Colors.blue[300]! : Colors.grey[300]!,
                          width: isLoanImage ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Document preview
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                    color: isLoanImage ? Colors.blue[100] : Colors.grey[100],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                    child: Image.network(
                                      HistoryLoanDocumentApi.getDocumentUrl(document.documentPath),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isLoanImage ? Colors.blue[300] : Colors.blueGrey[300],
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: isLoanImage ? Colors.blue[200] : Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isLoanImage ? Icons.image : Icons.description,
                                              color: isLoanImage ? Colors.blue[600] : Colors.grey[500],
                                              size: 32,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isLoanImage ? 'Loan Image' : 'Document',
                                              style: TextStyle(
                                                color: isLoanImage ? Colors.blue[600] : Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Badge for loan image
                                if (isLoanImage)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[600],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'LOAN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Document info
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        isLoanImage
                                          ? 'Loan Image'
                                          : (document.fileName.isNotEmpty ? document.fileName : 'Document ${index + 1}'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isLoanImage ? Colors.blue[700] : Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isLoanImage)
                                      Icon(
                                        Icons.star,
                                        color: Colors.blue[600],
                                        size: 14,
                                      ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
