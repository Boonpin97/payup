import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/trip.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'participants_screen.dart';

class TripSignInScreen extends StatefulWidget {
  const TripSignInScreen({super.key});

  @override
  State<TripSignInScreen> createState() => _TripSignInScreenState();
}

class _TripSignInScreenState extends State<TripSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripNameController = TextEditingController();
  final _signInCodeController = TextEditingController();
  final _firebaseService = FirebaseService();
  
  bool _isLoading = false;
  bool _isCreateMode = true;
  String? _errorMessage;

  @override
  void dispose() {
    _tripNameController.dispose();
    _signInCodeController.dispose();
    super.dispose();
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final trip = await _firebaseService.createTrip(_tripNameController.text.trim());
      
      if (!mounted) return;

      // Show success dialog with the sign-in code
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Trip Created!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your trip sign-in code is:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!, width: 2),
                ),
                child: Text(
                  trip.signInCode,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Share this code with your trip members!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            CustomButton(
              text: 'Continue',
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToParticipants(trip);
              },
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create trip: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _joinTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final trip = await _firebaseService.joinTrip(_signInCodeController.text.trim());
      
      if (!mounted) return;

      if (trip == null) {
        setState(() {
          _errorMessage = 'Invalid sign-in code. Please check and try again.';
        });
        return;
      }

      // Navigate to participants screen or summary based on setup status
      if (trip.participants.isEmpty) {
        _navigateToParticipants(trip);
      } else {
        // Navigate to summary screen
        Navigator.of(context).pushReplacementNamed(
          '/summary',
          arguments: trip,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to join trip: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToParticipants(Trip trip) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ParticipantsScreen(trip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo/Icon
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                // Title
                const Text(
                  'PayUp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Split expenses with friends',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                // Mode Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCreateMode = true;
                              _errorMessage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isCreateMode
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Create Trip',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isCreateMode
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCreateMode = false;
                              _errorMessage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isCreateMode
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Join Trip',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: !_isCreateMode
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Form Fields
                if (_isCreateMode) ...[
                  CustomTextField(
                    label: 'Trip Name',
                    hint: 'e.g., Beach Weekend, Europe 2024',
                    controller: _tripNameController,
                    prefixIcon: const Icon(Icons.luggage),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a trip name';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  CustomTextField(
                    label: 'Sign-In Code',
                    hint: 'Enter 6-digit code',
                    controller: _signInCodeController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.vpn_key),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the sign-in code';
                      }
                      if (value.trim().length != 6) {
                        return 'Code must be 6 digits';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
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
                // Submit Button
                CustomButton(
                  text: _isCreateMode ? 'Create Trip' : 'Join Trip',
                  onPressed: _isCreateMode ? _createTrip : _joinTrip,
                  isLoading: _isLoading,
                  icon: _isCreateMode ? Icons.add : Icons.login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
