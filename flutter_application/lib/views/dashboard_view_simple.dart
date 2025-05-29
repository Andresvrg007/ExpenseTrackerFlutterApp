import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'categories_view.dart';
import 'transactions_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green[700], // ✅ Cambio a verde
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
              await authViewModel.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[700]!, // ✅ Cambio a verde
              Colors.green[50]!,  // ✅ Cambio a verde claro
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with gradient background
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.green[50]!, // ✅ Cambio a verde
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[100], // ✅ Cambio a verde
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.waving_hand,
                                color: Colors.green[700], // ✅ Cambio a verde
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800], // ✅ Cambio a verde
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Manage your finances efficiently',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Financial Summary Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Summary',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              context,
                              'Balance',
                              '\$2,350.00',
                              Colors.green[600]!, // ✅ Cambio a verde para balance
                              Icons.account_balance_wallet,
                            ),
                            _buildSummaryItem(
                              context,
                              'Income',
                              '\$3,200.00',
                              Colors.green[600]!, // ✅ Mantener verde para income
                              Icons.trending_up,
                            ),
                            _buildSummaryItem(
                              context,
                              'Expenses',
                              '\$850.00',
                              Colors.red[600]!, // ✅ Mantener rojo para expenses
                              Icons.trending_down,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Actions Title
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Quick Actions Grid - OVERFLOW ARREGLADO
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2, // ✅ Aumentado de 1.1 a 1.2 para más altura
                    children: [
                      _buildActionCard(
                        context,
                        'Categories',
                        'Manage categories', // ✅ Texto más corto
                        Icons.category,
                        Colors.orange[600]!,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CategoriesView()),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        'Transactions',
                        'Manage transactions', // ✅ Texto más corto
                        Icons.receipt_long,
                        Colors.purple[600]!,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TransactionsView()),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        'Reports',
                        'View detailed reports',
                        Icons.bar_chart,
                        Colors.teal[600]!,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reports feature coming soon!')),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        'Settings',
                        'Configure preferences',
                        Icons.settings,
                        Colors.grey[600]!,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings feature coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0), // ✅ Reducido de 16 a 14
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // ✅ Reducido de 12 a 10
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28, // ✅ Reducido de 32 a 28
                    color: color,
                  ),
                ),
                const SizedBox(height: 10), // ✅ Reducido de 12 a 10
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 13, // ✅ Tamaño específico
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4), // ✅ Reducido de 6 a 4
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 10, // ✅ Reducido de 11 a 10
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
