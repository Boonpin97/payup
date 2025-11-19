import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'summary_screen.dart';

class ParticipantsScreen extends StatefulWidget {
  final Trip trip;

  const ParticipantsScreen({
    super.key,
    required this.trip,
  });

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final List<TextEditingController> _nameControllers = [];
  final List<FocusNode> _focusNodes = [];
  
  bool _isLoading = false;
  int _totalParticipants = 2;
  bool _showNameFields = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateParticipantCount(int newCount) {
    if (newCount < 1 || newCount > 20) return;

    setState(() {
      _totalParticipants = newCount;
    });
  }

  void _startEnteringNames() {
    setState(() {
      _showNameFields = true;
      _errorMessage = null;
      
      // Initialize controllers and focus nodes
      _nameControllers.clear();
      _focusNodes.clear();
      for (int i = 0; i < _totalParticipants; i++) {
        _nameControllers.add(TextEditingController());
        _focusNodes.add(FocusNode());
      }
    });
    
    // Focus on first field after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _goBack() {
    setState(() {
      _showNameFields = false;
      _errorMessage = null;
    });
  }

  void _focusNextField(int currentIndex) {
    if (currentIndex < _focusNodes.length - 1) {
      _focusNodes[currentIndex + 1].requestFocus();
    } else {
      // Last field, unfocus keyboard
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _saveParticipants() async {
    if (!_formKey.currentState!.validate()) return;

    // Collect all names
    final names = _nameControllers.map((controller) => controller.text.trim()).toList();
    
    // Check for duplicate names
    final uniqueNames = names.toSet();
    if (uniqueNames.length != names.length) {
      setState(() {
        _errorMessage = 'Duplicate names found. Please ensure all names are unique.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _firebaseService.addParticipants(widget.trip.id, names);
      
      if (!mounted) return;

      // Navigate to summary screen
      final updatedTrip = widget.trip.copyWith(participants: names);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SummaryScreen(trip: updatedTrip),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save participants: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Step 0: Select participant count
    if (!_showNameFields) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add Participants'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Trip Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.trip.tripName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Code: '),
                          Text(
                            widget.trip.signInCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'How many people are splitting expenses?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                // Participant Count Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 40),
                      onPressed: _totalParticipants > 1
                          ? () => _updateParticipantCount(_totalParticipants - 1)
                          : null,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '$_totalParticipants',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 40),
                      onPressed: _totalParticipants < 20
                          ? () => _updateParticipantCount(_totalParticipants + 1)
                          : null,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _totalParticipants == 1 ? 'person' : 'people',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                CustomButton(
                  text: 'Start Adding Names',
                  onPressed: _startEnteringNames,
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show all text fields for participant names
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Participants'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : _goBack,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Enter all participant names:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Generate text fields for all participants
                      ...List.generate(_totalParticipants, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomTextField(
                            label: 'Participant ${index + 1}',
                            hint: 'Enter name',
                            controller: _nameControllers[index],
                            focusNode: _focusNodes[index],
                            prefixIcon: const Icon(Icons.person),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _focusNextField(index),
                          ),
                        );
                      }),
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: CustomButton(
                  text: 'Next',
                  onPressed: () {
                    // Find the first empty field or the next unfilled field
                    int nextIndex = -1;
                    for (int i = 0; i < _nameControllers.length; i++) {
                      if (_nameControllers[i].text.trim().isEmpty) {
                        nextIndex = i;
                        break;
                      }
                    }
                    
                    if (nextIndex != -1) {
                      // Move to the next empty field
                      _focusNodes[nextIndex].requestFocus();
                    } else {
                      // All fields are filled, save participants
                      _saveParticipants();
                    }
                  },
                  isLoading: _isLoading,
                  icon: Icons.arrow_forward,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
