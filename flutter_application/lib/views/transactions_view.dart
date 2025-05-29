// views/transactions_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../models/transaction_model.dart' as TransactionModel;
import 'transaction_form_view.dart';
import 'package:intl/intl.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({Key? key}) : super(key: key);

  @override
  _TransactionsViewState createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Cargar transacciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Ingresos'),
            Tab(text: 'Gastos'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda y resumen
          _buildHeaderSection(),

          // Lista de transacciones
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(TransactionFilter.all),
                _buildTransactionList(TransactionFilter.income),
                _buildTransactionList(TransactionFilter.expense),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          color: Colors.grey[50],
          child: Column(
            children: [
              // Resumen de balance
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Ingresos',
                        viewModel.totalIncome,
                        Colors.green,
                        Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        'Gastos',
                        viewModel.totalExpenses,
                        Colors.red,
                        Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        'Balance',
                        viewModel.balance,
                        viewModel.balance >= 0 ? Colors.green : Colors.red,
                        Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
              ),

              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar transacciones...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              _currencyFormat.format(amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(TransactionFilter filter) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadTransactions(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Obtener transacciones según el filtro
        List<TransactionModel.Transaction> transactions =
            _getFilteredTransactions(viewModel, filter);

        // Aplicar búsqueda
        if (_searchQuery.isNotEmpty) {
          transactions = transactions
              .where(
                (transaction) =>
                    transaction.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    transaction.category.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
        }

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No se encontraron transacciones'
                      : 'No hay transacciones aún',
                  style: const TextStyle(fontSize: 16),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Toca el botón + para crear una',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.loadTransactions(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(context, transaction, viewModel);
            },
          ),
        );
      },
    );
  }

  List<TransactionModel.Transaction> _getFilteredTransactions(
    TransactionViewModel viewModel,
    TransactionFilter filter,
  ) {
    switch (filter) {
      case TransactionFilter.all:
        return viewModel.transactions;
      case TransactionFilter.income:
        return viewModel.incomeTransactions;
      case TransactionFilter.expense:
        return viewModel.expenseTransactions;
    }
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel.Transaction transaction,
    TransactionViewModel viewModel,
  ) {
    final isIncome =
        transaction.tipo == TransactionModel.TransactionType.ingreso.value;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.category,
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              _dateFormat.format(transaction.fecha),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${_currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleMenuAction(context, value, transaction, viewModel),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Editar'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    TransactionModel.Transaction transaction,
    TransactionViewModel viewModel,
  ) {
    switch (action) {
      case 'edit':
        _navigateToForm(context, transaction: transaction);
        break;
      case 'delete':
        _showDeleteDialog(context, transaction, viewModel);
        break;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    TransactionModel.Transaction transaction,
    TransactionViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${transaction.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await viewModel.deleteTransaction(
                transaction.id!,
              );
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transacción eliminada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(
    BuildContext context, {
    TransactionModel.Transaction? transaction,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionFormView(transaction: transaction),
      ),
    );
  }
}

enum TransactionFilter { all, income, expense }
