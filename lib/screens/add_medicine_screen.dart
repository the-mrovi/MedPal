import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMedicineScreen extends StatefulWidget {
  static const String routeName = '/medicine/add';

  const AddMedicineScreen({super.key});
  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _nameCtrl = TextEditingController();
  final _strengthCtrl = TextEditingController(text: '500');
  final _minutesCtrl = TextEditingController(text: '20');

  String _type = 'Tablet';
  String _unit = 'mg';
  int _totalDays = 10;
  int _amountPerDose = 2;
  bool _breakfast = true, _lunch = false, _dinner = true;
  String _mealTiming = 'After eating';
  bool _isSaving = false;

  @override
  void dispose() {
    for (var ctrl in [_nameCtrl, _strengthCtrl, _minutesCtrl]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter medicine name')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('medicines').insert({
        'patient_id': user?.id,
        'name': _nameCtrl.text.trim(),
        'medicine_type': _type,
        'strength': _strengthCtrl.text,
        'unit': _unit,
        'total_days': _totalDays,
        'take_breakfast': _breakfast,
        'take_lunch': _lunch,
        'take_dinner': _dinner,
        'meal_timing': _mealTiming,
        'dosage_per_dose': _amountPerDose,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Medicine',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _inputField(_nameCtrl, 'Medicine Name', 'e.g. Napa Extra'),
            const SizedBox(height: 16),
            _rowLabel('Type'),
            Row(
              children: ['Tablet', 'Capsule', 'Syrup']
                  .map(
                    (t) => Expanded(
                      child: _choiceChip(
                        t,
                        _type == t,
                        () => setState(() => _type = t),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _inputField(_strengthCtrl, 'Strength', ''),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _dropdownField()),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              'The Schedule',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _counterTile(
              'How long to take?',
              'Total days',
              _totalDays,
              (v) => setState(() => _totalDays = v),
            ),
            const SizedBox(height: 16),
            const Text(
              'Take at which meals?',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _mealBtn(
                  'Breakfast',
                  _breakfast,
                  (v) => setState(() => _breakfast = v),
                ),
                _mealBtn('Lunch', _lunch, (v) => setState(() => _lunch = v)),
                _mealBtn('Dinner', _dinner, (v) => setState(() => _dinner = v)),
              ],
            ),
            const SizedBox(height: 20),
            _dosageCard(),
            const SizedBox(height: 30),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _inputField(TextEditingController ctrl, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: secondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withOpacity(0.1) : secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primaryColor : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? primaryColor : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unit',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField(
          value: _unit,
          items: [
            'mg',
            'ml',
          ].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
          onChanged: (v) => setState(() => _unit = v!),
          decoration: InputDecoration(
            filled: true,
            fillColor: secondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mealBtn(String label, bool active, Function(bool) onChanged) {
    return Expanded(
      child: _choiceChip(label, active, () => onChanged(!active)),
    );
  }

  Widget _counterTile(
    String title,
    String subtitle,
    int val,
    Function(int) onUpdate,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => onUpdate(val > 1 ? val - 1 : 1),
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: primaryColor,
                ),
              ),
              Text('$val', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => onUpdate(val + 1),
                icon: const Icon(Icons.add_circle, color: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dosageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            'AMOUNT PER DOSE',
            style: TextStyle(
              color: primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () =>
                    setState(() => _amountPerDose > 1 ? _amountPerDose-- : 1),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$_amountPerDose',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _amountPerDose++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Text(
            '$_type${_amountPerDose > 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Medicine',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _rowLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );
}
