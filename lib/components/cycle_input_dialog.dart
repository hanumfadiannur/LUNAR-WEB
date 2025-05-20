import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CycleInputDialog extends StatefulWidget {
  final String userId, idToken;
  final VoidCallback onDataSaved;

  const CycleInputDialog({
    required this.userId,
    required this.idToken,
    required this.onDataSaved,
    Key? key,
  }) : super(key: key);

  @override
  _CycleInputDialogState createState() => _CycleInputDialogState();
}

class _CycleInputDialogState extends State<CycleInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final cycleController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  void saveData() async {
    if (_formKey.currentState!.validate() &&
        startDate != null &&
        endDate != null) {
      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/cycle'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.idToken}',
          },
          body: jsonEncode({
            'cycleLength': int.parse(cycleController.text),
            'lastPeriodStartDate': startDate!.toIso8601String(),
            'lastPeriodEndDate': endDate!.toIso8601String(),
          }),
        );

        if (response.statusCode == 200) {
          Get.snackbar(
            'Success',
            'Data saved successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          widget
              .onDataSaved(); // Callback untuk memberitahu bahwa data sudah disimpan
          Get.back(); // Tutup dialog
        } else {
          Get.snackbar(
            'Error',
            'Failed to save data: ${response.body}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to save data: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar('Invalid', 'Please fill all fields!',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _selectDate({
    required DateTime? initialDate,
    required ValueChanged<DateTime> onDateSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Cycle Information',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cycle Length Input
              TextFormField(
                controller: cycleController,
                decoration: InputDecoration(
                  labelText: 'Cycle Length (days)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (int.tryParse(val) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Start Date Picker
              GestureDetector(
                onTap: () => _selectDate(
                  initialDate: startDate ?? DateTime.now(),
                  onDateSelected: (pickedDate) {
                    setState(() {
                      startDate = pickedDate;
                    });
                  },
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startDate != null
                            ? 'Start Date: ${startDate!.toLocal().toString().split(' ')[0]}'
                            : 'Select Start Date',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // End Date Picker
              GestureDetector(
                onTap: () => _selectDate(
                  initialDate: endDate ?? DateTime.now(),
                  onDateSelected: (pickedDate) {
                    setState(() {
                      endDate = pickedDate;
                    });
                  },
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        endDate != null
                            ? 'End Date: ${endDate!.toLocal().toString().split(' ')[0]}'
                            : 'Select End Date',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: saveData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Save'),
        ),
      ],
    );
  }
}
