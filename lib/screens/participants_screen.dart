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
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  int _totalParticipants = 2;
  int _currentStep = 0; // 0 = select count, 1+ = entering names
  List<String> _enteredNames = [];
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
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
      _currentStep = 1;
      _nameController.clear();
      _errorMessage = null;
    });
  }

  void _nextName() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    
    // Check for duplicate names
    if (_enteredNames.contains(name)) {
      setState(() {
        _errorMessage = 'This name has already been added';
      });
      return;
    }

    setState(() {
      _enteredNames.add(name);
      _nameController.clear();
      _errorMessage = null;
      
      // Check if we've entered all names
      if (_enteredNames.length >= _totalParticipants) {
        _saveParticipants();
      } else {
        _currentStep++;
      }
    });
  }

  void _previousName() {
    if (_enteredNames.isEmpty) {
      setState(() {
        _currentStep = 0;
      });
    } else {
      setState(() {
        _enteredNames.removeLast();
        _currentStep--;
        _nameController.clear();
        _errorMessage = null;
      });
    }
  }

  Future<void> _saveParticipants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _firebaseService.addParticipants(widget.trip.id, _enteredNames);
      
      if (!mounted) return;

      // Navigate to summary screen
      final updatedTrip = widget.trip.copyWith(participants: _enteredNames);
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
    if (_currentStep == 0) {
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

    // Steps 1+: Enter participant names one by one
    final participantNumber = _enteredNames.length + 1;
    final isLastParticipant = participantNumber == _totalParticipants;

    return Scaffold(
      appBar: AppBar(
        title: Text('Participant $participantNumber of $_totalParticipants'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : _previousName,
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
                      // Progress indicator
                      LinearProgressIndicator(
                        value: _enteredNames.length / _totalParticipants,
                        backgroundColor: Colors.grey[200],
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 32),
                      // Already entered names
                      if (_enteredNames.isNotEmpty) ...[
                        const Text(
                          'Added participants:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _enteredNames.map((name) {
                            return Chip(
                              label: Text(name),
                              avatar: const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],
                      // Name input
                      Text(
                        isLastParticipant
                            ? 'Enter the last participant name:'
                            : 'Enter participant name:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Participant ${_enteredNames.length + 1}',
                        hint: 'Enter name',
                        controller: _nameController,
                        autofocus: true,
                        prefixIcon: const Icon(Icons.person),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _nextName(),
                      ),
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
                  text: isLastParticipant ? 'Finish & Continue' : 'Next',
                  onPressed: _nextName,
                  isLoading: _isLoading,
                  icon: isLastParticipant ? Icons.check : Icons.arrow_forward,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
