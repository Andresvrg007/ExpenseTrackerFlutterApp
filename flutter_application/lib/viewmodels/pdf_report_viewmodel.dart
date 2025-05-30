import 'package:flutter/foundation.dart';
import '../services/pdf_report_service.dart';
import '../models/transaction_model.dart' as TransactionModel;

class PDFReportViewModel extends ChangeNotifier {
  bool _isGenerating = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastReport;

  // Getters
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastReport => _lastReport;

  /// Método principal para generar PDF mensual
  Future<bool> generateMonthlyPDF({
    required List<TransactionModel.Transaction> transactions,
  }) async {
    try {
      _isGenerating = true;
      _errorMessage = null;
      notifyListeners();

      // Llamar al servicio de PDF con hilos paralelos
      final result = await PDFReportService.generateMonthlyPDFReport(
        allTransactions: transactions,
      );

      if (result['success'] == true) {
        _lastReport = result;
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Unknown error occurred';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  ///  Cerrar último reporte (para generar otro)
  void clearLastReport() {
    _lastReport = null;
    notifyListeners();
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtener estadísticas del último reporte
  Map<String, dynamic>? get lastReportStatistics {
    return _lastReport?['statistics'];
  }

  /// Verificar si hay un reporte generado
  bool get hasReport => _lastReport != null;

  /// Obtener ruta del último PDF generado
  String? get lastPDFPath => _lastReport?['filePath'];

  /// Obtener tiempo de procesamiento del último reporte
  int? get lastProcessingTime => _lastReport?['processingTime'];

  /// Resetear todo el estado
  void reset() {
    _isGenerating = false;
    _errorMessage = null;
    _lastReport = null;
    notifyListeners();
  }
}
