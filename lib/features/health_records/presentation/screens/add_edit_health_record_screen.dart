import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/date_utils.dart';
import '../../data/models/health_record.dart';
import '../providers/health_record_provider.dart';

class AddEditHealthRecordScreen extends StatefulWidget {
  const AddEditHealthRecordScreen({super.key, this.initialRecord});

  final HealthRecord? initialRecord;

  @override
  State<AddEditHealthRecordScreen> createState() => _AddEditHealthRecordScreenState();
}

class _AddEditHealthRecordScreenState extends State<AddEditHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _stepsController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _waterController;
  late DateTime _selectedDate;
  bool _submitting = false;

  bool get _isEditMode => widget.initialRecord != null;

  @override
  void initState() {
    super.initState();
    final record = widget.initialRecord;
    _selectedDate = record != null ? DateTime.parse(record.date) : DateTime.now();
    _stepsController = TextEditingController(text: record?.steps.toString() ?? '');
    _caloriesController = TextEditingController(text: record?.calories.toString() ?? '');
    _waterController = TextEditingController(text: record?.water.toString() ?? '');
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Update record' : 'Add record';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateField(context),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: _stepsController,
                label: 'Steps',
                icon: Icons.directions_walk,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: _caloriesController,
                label: 'Calories',
                icon: Icons.local_fire_department_outlined,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: _waterController,
                label: 'Water (ml)',
                icon: Icons.opacity,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : () => _submit(context),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditMode ? 'Update' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(AppDateUtils.formatDate(_selectedDate)),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter $label';
        }
        final parsed = int.tryParse(value);
        if (parsed == null || parsed < 0) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (selected != null) {
      setState(() => _selectedDate = selected);
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final provider = context.read<HealthRecordProvider>();
    final navigator = Navigator.of(context);
    final record = HealthRecord(
      id: widget.initialRecord?.id,
      date: AppDateUtils.formatDate(_selectedDate),
      steps: int.parse(_stepsController.text),
      calories: int.parse(_caloriesController.text),
      water: int.parse(_waterController.text),
    );

    try {
      if (_isEditMode) {
        await provider.updateRecord(record);
      } else {
        await provider.addRecord(record);
      }
      navigator.pop();
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
