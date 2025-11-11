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
  
  bool _isLoading = false;
  int _participantCount = 2;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameControllers.clear();
    for (int i = 0; i < _participantCount; i++) {
      _nameControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateParticipantCount(int newCount) {
    if (newCount < 1 || newCount > 20) return;

    setState(() {
      _participantCount = newCount;
      
      // Add or remove controllers as needed
      if (_nameControllers.length < newCount) {
        for (int i = _nameControllers.length; i < newCount; i++) {
          _nameControllers.add(TextEditingController());
        }
      } else if (_nameControllers.length > newCount) {
        for (int i = _nameControllers.length - 1; i >= newCount; i--) {
          _nameControllers[i].dispose();
          _nameControllers.removeAt(i);
        }
      }
    });
  }

  Future<void> _saveParticipants() async {
    if (!_formKey.currentState!.validate()) return;

    // Get participant names
    final participants = _nameControllers
        .map((controller) => controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (participants.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one participant';
      });
      return;
    }

    // Check for duplicate names
    final uniqueNames = participants.toSet();
    if (uniqueNames.length != participants.length) {
      setState(() {
        _errorMessage = 'Participant names must be unique';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _firebaseService.addParticipants(widget.trip.id, participants);
      
      if (!mounted) return;

      // Navigate to summary screen
      final updatedTrip = widget.trip.copyWith(participants: participants);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SummaryScreen(trip: updatedTrip),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save participants: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Participants'),
        centerTitle: true,
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
                      const SizedBox(height: 32),
                      // Participant Count Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Number of participants:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _participantCount > 1
                                ? () => _updateParticipantCount(_participantCount - 1)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_participantCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _participantCount < 20
                                ? () => _updateParticipantCount(_participantCount + 1)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Participant Name Fields
                      ...List.generate(_participantCount, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomTextField(
                            label: 'Participant ${index + 1}',
                            hint: 'Enter name',
                            controller: _nameControllers[index],
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
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
                  text: 'Continue',
                  onPressed: _saveParticipants,
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
