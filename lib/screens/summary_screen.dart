import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/expense.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/expense_card.dart';
import '../widgets/balance_card.dart';
import 'add_expense_screen.dart';

class SummaryScreen extends StatefulWidget {
  final Trip trip;

  const SummaryScreen({
    super.key,
    required this.trip,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _firebaseService = FirebaseService();
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final expenses = await _firebaseService.fetchExpenses(widget.trip.id);
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load expenses: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExpense(String expenseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firebaseService.deleteExpense(widget.trip.id, expenseId);
        _loadExpenses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  void _navigateToAddExpense() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(trip: widget.trip),
      ),
    );

    if (result == true) {
      _loadExpenses();
    }
  }

  Map<String, Map<String, double>> _calculateBalances() {
    return _firebaseService.calculateBalances(_expenses, widget.trip.participants);
  }

  double _calculateTotalExpenses() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    final balances = _calculateBalances();
    final totalExpenses = _calculateTotalExpenses();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.tripName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Trip Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trip Name: ${widget.trip.tripName}'),
                      const SizedBox(height: 8),
                      Text('Sign-In Code: ${widget.trip.signInCode}'),
                      const SizedBox(height: 8),
                      Text('Participants: ${widget.trip.participants.length}'),
                      const SizedBox(height: 12),
                      const Text(
                        'Participants:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...widget.trip.participants.map(
                        (name) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Text('• $name'),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Retry',
                          onPressed: _loadExpenses,
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      // Summary Header
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Total Expenses',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${totalExpenses.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_expenses.length} ${_expenses.length == 1 ? "expense" : "expenses"}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Balances Section
                      if (balances.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Settlements',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entries = balances.entries.toList();
                              final from = entries[index].key;
                              final owes = entries[index].value;
                              
                              if (owes.isEmpty) return const SizedBox.shrink();
                              
                              return Column(
                                children: owes.entries.map((entry) {
                                  return BalanceCard(
                                    from: from,
                                    to: entry.key,
                                    amount: entry.value,
                                  );
                                }).toList(),
                              );
                            },
                            childCount: balances.length,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      ],
                      // Expenses Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt_long, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Expenses',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expense List
                      if (_expenses.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No expenses yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add one',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ExpenseCard(
                                expense: _expenses[index],
                                onDelete: () => _deleteExpense(_expenses[index].id),
                              );
                            },
                            childCount: _expenses.length,
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
