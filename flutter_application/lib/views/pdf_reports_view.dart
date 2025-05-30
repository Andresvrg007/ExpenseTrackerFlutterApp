import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/pdf_report_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';

class PDFReportsView extends StatefulWidget {
  const PDFReportsView({Key? key}) : super(key: key);

  @override
  _PDFReportsViewState createState() => _PDFReportsViewState();
}

class _PDFReportsViewState extends State<PDFReportsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Reports'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[50]!],
          ),
        ),
        child: Consumer2<PDFReportViewModel, TransactionViewModel>(
          builder: (context, pdfViewModel, transactionViewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.picture_as_pdf, color: Colors.red[600], size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Generate Monthly PDF Report',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '4 parallel threads - Current month transactions',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: pdfViewModel.isGenerating 
                                ? null 
                                : () => _generatePDF(context, pdfViewModel, transactionViewModel),
                              icon: pdfViewModel.isGenerating 
                                ? SizedBox(
                                    width: 16, height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(Icons.play_arrow),
                              label: Text(
                                pdfViewModel.isGenerating ? 'Generating PDF...' : 'Generate PDF Report',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ SOLO BARRA DE PROGRESO (SIN LOGS)
                  if (pdfViewModel.isGenerating) ...[
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'Processing with 4 parallel threads...',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Filtering transactions, calculating statistics, generating content...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ✅ RESULTADOS CON BOTÓN CERRAR (MANTENER COMO ESTÁ)
                  if (pdfViewModel.lastReport != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'PDF Generated Successfully!',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                                // ✅ BOTÓN CERRAR PDF
                                IconButton(
                                  onPressed: () => pdfViewModel.clearLastReport(),
                                  icon: Icon(Icons.close, color: Colors.grey[600]),
                                  tooltip: 'Close PDF result',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildResultRow('File Name', pdfViewModel.lastReport!['fileName']),
                            _buildResultRow('Processing Time', '${pdfViewModel.lastReport!['processingTime']}ms'),
                            _buildResultRow('Threads Used', '${pdfViewModel.lastReport!['threadsUsed']}'),
                            _buildResultRow('Transactions', '${pdfViewModel.lastReport!['transactionsFiltered']}'),
                            _buildResultRow('File Size', '${(pdfViewModel.lastReport!['fileSize'] / 1024).round()} KB'),
                            const SizedBox(height: 16),
                            
                            // ✅ BOTONES MEJORADOS
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openPDF(pdfViewModel.lastReport!['filePath']),
                                    icon: Icon(Icons.open_in_new),
                                    label: Text('Open PDF'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showFileLocation(pdfViewModel.lastReport!['filePath']),
                                    icon: Icon(Icons.folder_open),
                                    label: Text('Show Location'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[600],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Error Display
                  if (pdfViewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                pdfViewModel.errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                                softWrap: true,
                              ),
                            ),
                            IconButton(
                              onPressed: pdfViewModel.clearError,
                              icon: Icon(Icons.close, color: Colors.red[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ✅ INFORMACIÓN ADICIONAL (CUANDO NO HAY PDF NI ERROR)
                  if (!pdfViewModel.isGenerating && pdfViewModel.lastReport == null && pdfViewModel.errorMessage == null) ...[
                    const SizedBox(height: 24),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Generate your first PDF report',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click the button above to create a monthly financial report\nusing 4 parallel processing threads',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label, 
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value, 
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF(
    BuildContext context,
    PDFReportViewModel pdfViewModel,
    TransactionViewModel transactionViewModel,
  ) async {
    final success = await pdfViewModel.generateMonthlyPDF(
      transactions: transactionViewModel.transactions,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF report generated successfully using 4 parallel threads!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _openPDF(String filePath) async {
    try {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showFileLocation(filePath);
      }
    } catch (e) {
      _showFileLocation(filePath);
    }
  }

  void _showFileLocation(String filePath) {
    final fileName = filePath.split('/').last;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text('PDF Generated!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your PDF has been saved successfully!', 
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(fileName, 
                             style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('📁 Location:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Downloads → FinanceReports', 
                       style: TextStyle(color: Colors.blue[700], fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📱 How to open:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _buildStep('1', 'Open Samsung File Manager'),
                  _buildStep('2', 'Navigate to Downloads folder'),
                  _buildStep('3', 'Open FinanceReports folder'),
                  _buildStep('4', 'Tap on the PDF file'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it!', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}