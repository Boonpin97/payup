import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trip.dart';
import '../models/expense.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddExpenseScreen extends StatefulWidget {
  final Trip trip;
  final Expense? expense; // Optional expense for editing

  const AddExpenseScreen({
    super.key,
    required this.trip,
    this.expense,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final _expenseNameController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _selectedPayer;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  
  // Split options
  bool _isEvenSplit = true;
  Map<String, bool> _selectedParticipants = {};
  Map<String, TextEditingController> _customAmountControllers = {};

  @override
  void initState() {
    super.initState();
    
    // If editing, populate fields with existing expense data
    if (widget.expense != null) {
      _expenseNameController.text = widget.expense!.name;
      _amountController.text = widget.expense!.amount.toStringAsFixed(2);
      _selectedPayer = widget.expense!.payer;
      _selectedDate = widget.expense!.dateTime;
      
      // Initialize split data
      final splitData = widget.expense!.splitAmong;
      for (var participant in widget.trip.participants) {
        _selectedParticipants[participant] = splitData.containsKey(participant);
        _customAmountControllers[participant] = TextEditingController(
          text: splitData[participant]?.toStringAsFixed(2) ?? '0.00'
        );
      }
      
      // Determine if it's an even split
      if (splitData.isNotEmpty) {
        final amounts = splitData.values.toSet();
        _isEvenSplit = amounts.length == 1; // All amounts are the same
      }
    } else {
      // Initialize all participants as selected for even split (new expense)
      for (var participant in widget.trip.participants) {
        _selectedParticipants[participant] = true;
        _customAmountControllers[participant] = TextEditingController(text: '0.00');
      }
    }
    
    // Set first participant as default payer if none selected
    if (_selectedPayer == null && widget.trip.participants.isNotEmpty) {
      _selectedPayer = widget.trip.participants.first;
    }
  }

  @override
  void dispose() {
    _expenseNameController.dispose();
    _amountController.dispose();
    for (var controller in _customAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, double> _calculateSplit() {
    Map<String, double> splitAmong = {};
    
    if (_isEvenSplit) {
      // Even split among selected participants
      final selectedCount = _selectedParticipants.values.where((v) => v).length;
      if (selectedCount == 0) return {};
      
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final perPerson = amount / selectedCount;
      
      _selectedParticipants.forEach((participant, isSelected) {
        if (isSelected) {
          splitAmong[participant] = perPerson;
        }
      });
    } else {
      // Custom split
      _customAmountControllers.forEach((participant, controller) {
        final amount = double.tryParse(controller.text) ?? 0.0;
        if (amount > 0) {
          splitAmong[participant] = amount;
        }
      });
    }
    
    return splitAmong;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPayer == null) {
      setState(() {
        _errorMessage = 'Please select who paid';
      });
      return;
    }

    final splitAmong = _calculateSplit();
    
    if (splitAmong.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one participant for the split';
      });
      return;
    }

    // Validate custom split totals match expense amount
    if (!_isEvenSplit) {
      final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
      final splitTotal = splitAmong.values.fold(0.0, (sum, amount) => sum + amount);
      
      if ((totalAmount - splitTotal).abs() > 0.01) {
        setState(() {
          _errorMessage = 'Split amounts must equal total expense (\$${totalAmount.toStringAsFixed(2)})';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.expense != null) {
        // Update existing expense
        await _firebaseService.updateExpense(
          tripId: widget.trip.id,
          expenseId: widget.expense!.id,
          name: _expenseNameController.text.trim(),
          amount: double.parse(_amountController.text),
          payer: _selectedPayer!,
          splitAmong: splitAmong,
          dateTime: _selectedDate,
        );
      } else {
        // Add new expense
        await _firebaseService.addExpense(
          tripId: widget.trip.id,
          name: _expenseNameController.text.trim(),
          amount: double.parse(_amountController.text),
          payer: _selectedPayer!,
          splitAmong: splitAmong,
          dateTime: _selectedDate,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save expense: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleSplitMode() {
    setState(() {
      _isEvenSplit = !_isEvenSplit;
      _errorMessage = null;
    });
  }

  void _distributeEvenly() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final participantCount = widget.trip.participants.length;
    
    if (participantCount == 0) return;
    
    final perPerson = amount / participantCount;
    
    setState(() {
      for (var participant in widget.trip.participants) {
        _customAmountControllers[participant]!.text = perPerson.toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Expense Name
                    CustomTextField(
                      label: 'Expense Name',
                      hint: 'e.g., Dinner, Hotel, Gas',
                      controller: _expenseNameController,
                      prefixIcon: const Icon(Icons.receipt),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter expense name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Amount
                    CustomTextField(
                      label: 'Amount',
                      hint: '0.00',
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.attach_money),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Payer Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paid By',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedPayer,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          items: widget.trip.participants.map((participant) {
                            return DropdownMenuItem(
                              value: participant,
                              child: Text(participant),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPayer = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Date/Time Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date & Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey),
                                const SizedBox(width: 12),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} • ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Split Mode Toggle
                    Row(
                      children: [
                        const Text(
                          'Split Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (!_isEvenSplit) _toggleSplitMode();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isEvenSplit
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Even',
                                    style: TextStyle(
                                      color: _isEvenSplit
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_isEvenSplit) _toggleSplitMode();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_isEvenSplit
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Custom',
                                    style: TextStyle(
                                      color: !_isEvenSplit
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Split Among Section
                    if (_isEvenSplit) ...[
                      const Text(
                        'Split Among',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.trip.participants.map((participant) {
                        return CheckboxListTile(
                          title: Text(participant),
                          value: _selectedParticipants[participant] ?? false,
                          onChanged: (value) {
                            setState(() {
                              _selectedParticipants[participant] = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: Colors.grey[50],
                        );
                      }).toList(),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Custom Split',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.auto_fix_high, size: 16),
                            label: const Text('Auto-fill'),
                            onPressed: _distributeEvenly,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...widget.trip.participants.map((participant) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  participant,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _customAmountControllers[participant],
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    prefixText: '\$ ',
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    const SizedBox(height: 16),
                    // Error Message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            // Bottom Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: CustomButton(
                text: widget.expense != null ? 'Update Expense' : 'Save Expense',
                onPressed: _saveExpense,
                isLoading: _isLoading,
                icon: Icons.check,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
