// views/transaction_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../models/transaction_model.dart' as TransactionModel;
import '../models/category_model.dart' as CategoryModel;
import 'package:intl/intl.dart';

class TransactionFormView extends StatefulWidget {
  final TransactionModel.Transaction? transaction;

  const TransactionFormView({Key? key, this.transaction}) : super(key: key);

  @override
  _TransactionFormViewState createState() => _TransactionFormViewState();
}

class _TransactionFormViewState extends State<TransactionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  TransactionModel.TransactionType _selectedType =
      TransactionModel.TransactionType.gasto;
  CategoryModel.Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'efectivo';

  final List<String> _paymentMethods = ['efectivo', 'tarjeta', 'transferencia'];

  @override
  void initState() {
    super.initState();

    // Cargar categorías al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().loadCategories();
    });
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
      _selectedType = widget.transaction!.tipo == 'ingreso'
          ? TransactionModel.TransactionType.ingreso
          : TransactionModel.TransactionType.gasto;
      _selectedDate = widget.transaction!.fecha;
      // _selectedCategory se establecerá cuando se carguen las categorías
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Transacción' : 'Nueva Transacción'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<TransactionViewModel, CategoryViewModel>(
        builder: (context, transactionViewModel, categoryViewModel, child) {
          // Establecer categoría seleccionada cuando se carguen las categorías
          if (widget.transaction != null &&
              _selectedCategory == null &&
              categoryViewModel.categories.isNotEmpty) {
            _selectedCategory = categoryViewModel.categories.firstWhere(
              (cat) => cat.nombre == widget.transaction!.category,
              orElse: () => categoryViewModel.categories.first,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de transacción
                  const Text(
                    'Tipo de Transacción',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<TransactionModel.TransactionType>(
                          title: const Text('Ingreso'),
                          value: TransactionModel.TransactionType.ingreso,
                          groupValue: _selectedType,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                              _selectedCategory =
                                  null; // Reset category selection
                            });
                          },
                          tileColor: Colors.green[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RadioListTile<TransactionModel.TransactionType>(
                          title: const Text('Gasto'),
                          value: TransactionModel.TransactionType.gasto,
                          groupValue: _selectedType,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                              _selectedCategory =
                                  null; // Reset category selection
                            });
                          },
                          tileColor: Colors.red[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Monto
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: '\$ ',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El monto es requerido';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null || amount <= 0) {
                        return 'Ingresa un monto válido mayor a 0';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es requerida';
                      }
                      if (value.trim().length < 3) {
                        return 'La descripción debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Categoría
                  const Text(
                    'Categoría',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (categoryViewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (categoryViewModel.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        'Error cargando categorías: ${categoryViewModel.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    _buildCategorySelector(categoryViewModel),

                  const SizedBox(height: 16),

                  // Fecha
                  const Text(
                    'Fecha',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Método de pago
                  const Text(
                    'Método de Pago',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(_getPaymentMethodName(method)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Botón guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: transactionViewModel.isLoading
                          ? null
                          : _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: transactionViewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing ? 'Actualizar' : 'Crear',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  if (transactionViewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        transactionViewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector(CategoryViewModel categoryViewModel) {
    final availableCategories =
        _selectedType == TransactionModel.TransactionType.ingreso
        ? categoryViewModel.incomeCategories
        : categoryViewModel.expenseCategories;

    if (availableCategories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Text(
          'No hay categorías de ${_selectedType == TransactionModel.TransactionType.ingreso ? 'ingreso' : 'gasto'} disponibles. Crea una categoría primero.',
          style: const TextStyle(color: Colors.orange),
        ),
      );
    }

    return DropdownButtonFormField<CategoryModel.Category>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
        hintText: 'Selecciona una categoría',
      ),
      items: availableCategories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _parseColor(category.color),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _parseIcon(category.icono),
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(category.nombre),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecciona una categoría';
        }
        return null;
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final transactionViewModel = context.read<TransactionViewModel>();
    transactionViewModel.clearError();

    final amount = double.parse(_amountController.text.trim());
    final description = _descriptionController.text.trim();
    bool success;
    if (widget.transaction != null) {
      // Editar transacción existente
      success = await transactionViewModel.updateTransaction(
        id: widget.transaction!.id!,
        amount: amount,
        description: description,
        category: _selectedCategory!.nombre,
        type: _selectedType.apiValue,
      );
    } else {
      // Crear nueva transacción
      success = await transactionViewModel.createTransaction(
        amount: amount,
        description: description,
        category: _selectedCategory!.nombre,
        categoryId: _selectedCategory!.id,
        type: _selectedType.apiValue,
        metodoPago: _selectedPaymentMethod,
      );
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction != null
                ? 'Transacción actualizada exitosamente'
                : 'Transacción creada exitosamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta';
      case 'transferencia':
        return 'Transferencia';
      default:
        return method;
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_cart;
      case 'health':
        return Icons.local_hospital;
      case 'entertainment':
        return Icons.movie;
      case 'home':
        return Icons.home;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}
