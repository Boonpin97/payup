import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _navigateToAddExpense({Expense? expense}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          trip: widget.trip,
          expense: expense,
        ),
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
                      const SizedBox(height: 16),
                      const Text(
                        'Sign-In Code:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              widget.trip.signInCode,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: widget.trip.signInCode),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Code copied to clipboard!'),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            tooltip: 'Copy code',
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                : DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        // Summary Header
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Expenses', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                                  const SizedBox(height: 6),
                  Text('\$${totalExpenses.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  '${_expenses.length} ${_expenses.length == 1 ? "expense" : "expenses"}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tabs
                        TabBar(
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          tabs: const [
                            Tab(icon: Icon(Icons.account_balance), text: 'Settlements'),
                            Tab(icon: Icon(Icons.receipt_long), text: 'Expenses'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Content
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Settlements tab
                              balances.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No settlements required yet',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                      itemCount: balances.length,
                                      itemBuilder: (context, index) {
                                        final entries = balances.entries.toList();
                                        final from = entries[index].key;
                                        final owes = entries[index].value;
                                        if (owes.isEmpty) return const SizedBox.shrink();
                                        return Column(
                                          children: owes.entries
                                              .map((entry) => BalanceCard(from: from, to: entry.key, amount: entry.value))
                                              .toList(),
                                        );
                                      },
                                    ),
                              // Expenses tab
                              _expenses.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.receipt_outlined, size: 80, color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          Text('No expenses yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                                          const SizedBox(height: 8),
                                          Text('Tap the + button to add one', style: TextStyle(color: Colors.grey[500])),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(bottom: 96),
                                      itemCount: _expenses.length,
                                      itemBuilder: (context, index) {
                                        return ExpenseCard(
                                          expense: _expenses[index],
                                          onEdit: () => _navigateToAddExpense(expense: _expenses[index]),
                                          onDelete: () => _deleteExpense(_expenses[index].id),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
