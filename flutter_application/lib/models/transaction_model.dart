// models/transaction_model.dart
class Transaction {
  final String? id;
  final String userId;
  final double amount;
  final String category;
  final String? categoryId;
  final String description;
  final String tipo; // 'ingreso' or 'gasto'
  final DateTime fecha;
  final List<String>? etiquetas;
  final String metodoPago;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.categoryId,
    required this.description,
    required this.tipo,
    required this.fecha,
    this.etiquetas,
    this.metodoPago = 'efectivo',
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      categoryId: json['categoryId'],
      description: json['description'] ?? '',
      tipo: json['tipo'] ?? json['type'] ?? '',
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      etiquetas: json['etiquetas'] != null
          ? List<String>.from(json['etiquetas'])
          : null,
      metodoPago: json['metodoPago'] ?? 'efectivo',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Method to convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category,
      'categoryId': categoryId,
      'description': description,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
      'etiquetas': etiquetas,
      'metodoPago': metodoPago,
    };
  }

  // Method to convert Transaction to API format
  Map<String, dynamic> toApiJson() {
    return {
      'amount': amount,
      'description': description,
      'category': category,
      'categoryId': categoryId,
      'type': tipo == 'ingreso' ? 'income' : 'expense',
      'metodoPago': metodoPago,
    };
  }

  // Method to create a copy with updated fields
  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? categoryId,
    String? description,
    String? tipo,
    DateTime? fecha,
    List<String>? etiquetas,
    String? metodoPago,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      etiquetas: etiquetas ?? this.etiquetas,
      metodoPago: metodoPago ?? this.metodoPago,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, category: $category, tipo: $tipo, fecha: $fecha)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.category == category &&
        other.description == description &&
        other.tipo == tipo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        description.hashCode ^
        tipo.hashCode;
  }
}

// Enum for transaction types
enum TransactionType { ingreso, gasto }

extension TransactionTypeExtension on TransactionType {
  String get value {
    switch (this) {
      case TransactionType.ingreso:
        return 'ingreso';
      case TransactionType.gasto:
        return 'gasto';
    }
  }

  String get displayName {
    switch (this) {
      case TransactionType.ingreso:
        return 'Ingreso';
      case TransactionType.gasto:
        return 'Gasto';
    }
  }

  String get apiValue {
    switch (this) {
      case TransactionType.ingreso:
        return 'income';
      case TransactionType.gasto:
        return 'expense';
    }
  }
}

// Enum for payment methods
enum PaymentMethod { efectivo, tarjeta, transferencia }

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.efectivo:
        return 'efectivo';
      case PaymentMethod.tarjeta:
        return 'tarjeta';
      case PaymentMethod.transferencia:
        return 'transferencia';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.efectivo:
        return 'Efectivo';
      case PaymentMethod.tarjeta:
        return 'Tarjeta';
      case PaymentMethod.transferencia:
        return 'Transferencia';
    }
  }
}
