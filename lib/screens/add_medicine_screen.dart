import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  static const routeName = '/medicine/add';

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

enum MedicineType { tablet, capsule, syrup }

enum MealTiming { before, after }

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _medicineNameCtrl = TextEditingController();
  final _strengthCtrl = TextEditingController(text: '500');
  final _minutesCtrl = TextEditingController(text: '20');

  MedicineType _type = MedicineType.tablet;
  String _unit = 'mg';

  int _totalDays = 10;

  bool _breakfast = true;
  bool _lunch = false;
  bool _dinner = true;

  MealTiming _mealTiming = MealTiming.after;

  int _amountPerDose = 2;

  bool _isSaving = false;

  @override
  void dispose() {
    _medicineNameCtrl.dispose();
    _strengthCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  String _typeLabel(MedicineType t) {
    switch (t) {
      case MedicineType.tablet:
        return 'Tablet';
      case MedicineType.capsule:
        return 'Capsule';
      case MedicineType.syrup:
        return 'Syrup';
    }
  }

  Future<void> _save() async {
    final name = _medicineNameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medicine name')),
      );
      return;
    }

    if (!_breakfast && !_lunch && !_dinner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one meal')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // TODO: Persist to DB when your medicine table is ready.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine saved (UI only)')),
      );
      Navigator.of(context).maybePop();
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
          'Add Medicine',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'Basic Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const _FieldLabel('Medicine Name'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _medicineNameCtrl,
                        decoration: InputDecoration(
                          hintText: 'e.g., Napa Extra',
                          filled: true,
                          fillColor: secondaryColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const _FieldLabel('Type'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeChip(
                              label: 'Tablet',
                              selected: _type == MedicineType.tablet,
                              onTap: () => setState(() => _type = MedicineType.tablet),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TypeChip(
                              label: 'Capsule',
                              selected: _type == MedicineType.capsule,
                              onTap: () => setState(() => _type = MedicineType.capsule),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TypeChip(
                              label: 'Syrup',
                              selected: _type == MedicineType.syrup,
                              onTap: () => setState(() => _type = MedicineType.syrup),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Strength'),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _strengthCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: secondaryColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Unit'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _unit,
                                  items: const [
                                    DropdownMenuItem(value: 'mg', child: Text('mg')),
                                    DropdownMenuItem(value: 'ml', child: Text('ml')),
                                  ],
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() => _unit = v);
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: secondaryColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      const Divider(height: 1),
                      const SizedBox(height: 18),
                      const Text(
                        'The Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'How long to\n take?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Total days',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _Stepper(
                              value: _totalDays,
                              onMinus: _totalDays <= 1
                                  ? null
                                  : () => setState(() => _totalDays -= 1),
                              onPlus: () => setState(() => _totalDays += 1),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Take at which meals? (Select all that apply)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MealToggle(
                              label: 'Breakfast',
                              selected: _breakfast,
                              onTap: () => setState(() => _breakfast = !_breakfast),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MealToggle(
                              label: 'Lunch',
                              selected: _lunch,
                              onTap: () => setState(() => _lunch = !_lunch),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MealToggle(
                              label: 'Dinner',
                              selected: _dinner,
                              onTap: () => setState(() => _dinner = !_dinner),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const _FieldLabel('Meal Timing'),
                      const SizedBox(height: 10),
                      _Segmented(
                        left: 'Before eating',
                        right: 'After eating',
                        selectedRight: _mealTiming == MealTiming.after,
                        onSelectLeft: () => setState(() => _mealTiming = MealTiming.before),
                        onSelectRight: () => setState(() => _mealTiming = MealTiming.after),
                      ),

                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Set minutes before/after meal',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Icon(Icons.info_outline, size: 16, color: Colors.black45),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minutesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('min', style: TextStyle(color: Colors.black54)),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Dosage Amount',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'AMOUNT PER DOSE',
                              style: TextStyle(
                                color: primaryColor.withAlpha(204),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _CircleIconButton(
                                  icon: Icons.remove,
                                  onTap: _amountPerDose <= 1
                                      ? null
                                      : () => setState(() => _amountPerDose -= 1),
                                ),
                                const SizedBox(width: 18),
                                Column(
                                  children: [
                                    Text(
                                      '$_amountPerDose',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      _typeLabel(_type) + (_amountPerDose == 1 ? '' : 's'),
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 18),
                                _CircleIconButton(
                                  icon: Icons.add,
                                  onTap: () => setState(() => _amountPerDose += 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Scheduled for ${_scheduleLabel()}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Medicine',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
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

  String _scheduleLabel() {
    final meals = <String>[];
    if (_breakfast) meals.add('Breakfast');
    if (_lunch) meals.add('Lunch');
    if (_dinner) meals.add('Dinner');
    return meals.isEmpty ? '-' : meals.join(' & ');
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withAlpha(20) : secondaryColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primaryColor.withAlpha(89) : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? primaryColor : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

class _MealToggle extends StatelessWidget {
  const _MealToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withAlpha(20) : secondaryColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primaryColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: selected ? primaryColor : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.left,
    required this.right,
    required this.selectedRight,
    required this.onSelectLeft,
    required this.onSelectRight,
  });

  final String left;
  final String right;
  final bool selectedRight;
  final VoidCallback onSelectLeft;
  final VoidCallback onSelectRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onSelectLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedRight ? Colors.transparent : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selectedRight ? Colors.black54 : primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onSelectRight,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedRight ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    right,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selectedRight ? primaryColor : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniIconButton(icon: Icons.remove, onTap: onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          _MiniIconButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 18, color: enabled ? primaryColor : Colors.black26),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, color: enabled ? primaryColor : Colors.black26),
      ),
    );
  }
}
