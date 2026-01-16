import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddRoutineScreen extends StatefulWidget {
  const AddRoutineScreen({super.key});

  static const routeName = '/routine/add';

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  // 1. Text Controllers to display selected times in the UI
  final _wakeUpCtrl = TextEditingController();
  final _breakfastCtrl = TextEditingController();
  final _lunchCtrl = TextEditingController();
  final _dinnerCtrl = TextEditingController();
  final _sleepCtrl = TextEditingController();

  // 2. State variables to hold the actual TimeOfDay objects
  TimeOfDay? _wakeUp;
  TimeOfDay? _breakfast;
  TimeOfDay? _lunch;
  TimeOfDay? _dinner;
  TimeOfDay? _sleep;

  bool _isSaving = false;

  @override
  void dispose() {
    _wakeUpCtrl.dispose();
    _breakfastCtrl.dispose();
    _lunchCtrl.dispose();
    _dinnerCtrl.dispose();
    _sleepCtrl.dispose();
    super.dispose();
  }

  // Helper to convert TimeOfDay to "HH:mm:ss" for Supabase/Postgres
  String _toTimeString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }

  // 3. Time Picker Logic
  Future<void> _pickTime({
    required TextEditingController controller,
    required TimeOfDay? initial,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
    );

    if (!mounted || picked == null) return;

    final formatted = MaterialLocalizations.of(context)
        .formatTimeOfDay(picked, alwaysUse24HourFormat: false);

    setState(() {
      controller.text = formatted;
      onPicked(picked);
    });
  }

  // 4. Save Logic: Validates fields and sends to Supabase
  Future<void> _saveRoutine() async {
    final missing = <String>[];
    if (_wakeUp == null) missing.add('Wake-up');
    if (_breakfast == null) missing.add('Breakfast');
    if (_lunch == null) missing.add('Lunch');
    if (_dinner == null) missing.add('Dinner');
    if (_sleep == null) missing.add('Sleeping-time');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please set: ${missing.join(', ')}')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      // Save to public.routines table
      await Supabase.instance.client.from('routines').upsert({
        'id': user.id,
        'wake_up': _toTimeString(_wakeUp!),
        'breakfast': _toTimeString(_breakfast!),
        'lunch': _toTimeString(_lunch!),
        'dinner': _toTimeString(_dinner!),
        'sleep': _toTimeString(_sleep!),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine saved successfully')),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving routine: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.black87),
            ),
          ),
        ),
        title: const Text(
          'Add New Routine',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 18),
                      const Text(
                        'Fill out the fields and hit the Save\nyour Routine',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 5. Individual Time Input Fields
                      _TimeField(
                        label: 'Weak-up*',
                        hintText: 'time (e.g. 8:00 AM)',
                        controller: _wakeUpCtrl,
                        onTap: () => _pickTime(
                          controller: _wakeUpCtrl,
                          initial: _wakeUp,
                          onPicked: (t) => _wakeUp = t,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TimeField(
                        label: 'Breakfast*',
                        hintText: 'time (e.g. 9:00 AM)',
                        controller: _breakfastCtrl,
                        onTap: () => _pickTime(
                          controller: _breakfastCtrl,
                          initial: _breakfast,
                          onPicked: (t) => _breakfast = t,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TimeField(
                        label: 'Lunch*',
                        hintText: 'time (e.g. 2:00 PM)',
                        controller: _lunchCtrl,
                        onTap: () => _pickTime(
                          controller: _lunchCtrl,
                          initial: _lunch,
                          onPicked: (t) => _lunch = t,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TimeField(
                        label: 'Dinner*',
                        hintText: 'time (e.g. 9:00 PM)',
                        controller: _dinnerCtrl,
                        onTap: () => _pickTime(
                          controller: _dinnerCtrl,
                          initial: _dinner,
                          onPicked: (t) => _dinner = t,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TimeField(
                        label: 'Sleeping-time*',
                        hintText: 'time (e.g. 10:00 PM)',
                        controller: _sleepCtrl,
                        onTap: () => _pickTime(
                          controller: _sleepCtrl,
                          initial: _sleep,
                          onPicked: (t) => _sleep = t,
                        ),
                      ),

                      const SizedBox(height: 40),
                      // 6. Save Button with Loading State
                      Center(
                        child: SizedBox(
                          width: 160,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveRoutine,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSaving 
                                ? const SizedBox(
                                    height: 20, 
                                    width: 20, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 7. Reusable Custom TextField Widget
class _TimeField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true, // Prevents keyboard from appearing
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black38),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}