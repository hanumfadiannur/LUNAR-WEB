import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lunar/routes/app_routes.dart';

class CycleInputDialog extends StatefulWidget {
  final String userId;
  const CycleInputDialog({required this.userId});

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
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(widget.userId);
        final year = startDate!.year.toString();
        final month = startDate!.month.toString().padLeft(2, '0');
        final periodLength = endDate!.difference(startDate!).inDays;

        // 1. Simpan data utama user (merge)
        await userRef.set({
          'cycleLength': int.parse(cycleController.text),
          'lastPeriodStartDate': Timestamp.fromDate(startDate!),
          'lastPeriodEndDate': Timestamp.fromDate(endDate!),
          'periodLength': (endDate!.difference(startDate!).inDays +
              1), // hitung panjang menstruasi
        }, SetOptions(merge: true));

        // 2. Simpan data periode ke subcollection 'periods/{year}/{month}/'
        await userRef
            .collection('periods')
            .doc(year)
            .collection(month)
            .doc('active')
            .set({
          'start_date': Timestamp.fromDate(startDate!),
          'end_date': Timestamp.fromDate(endDate!),
          'notes': {},
          'periodLength': (endDate!.difference(startDate!).inDays + 1),
        });

        // 3. Hitung prediksi periode berikutnya
        DateTime predictedStart =
            startDate!.add(Duration(days: int.parse(cycleController.text)));
        DateTime predictedEnd =
            predictedStart.add(Duration(days: periodLength));

        final predYear = predictedStart.year.toString();
        final predMonth = predictedStart.month.toString().padLeft(2, '0');

        // 4. Simpan prediksi ke subcollection 'predictions/{year}/{month}/'
        await userRef
            .collection('predictions')
            .doc(predYear)
            .collection(predMonth)
            .doc('active')
            .set({
          'predicted_start': Timestamp.fromDate(predictedStart),
          'predicted_end': Timestamp.fromDate(predictedEnd),
          'created_at': FieldValue.serverTimestamp(),
          'is_confirmed': false,
        });

        // 5. Snackbar sukses + redirect
        Get.snackbar(
          'Success',
          'Data saved successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.back();
        Get.offAllNamed(AppRoutes
            .home); // pastikan route `home` sudah didaftarkan di AppRoutes
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

              // Start Date
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(Duration(days: 30)),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => startDate = picked);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        'Select Start Date: ',
                        style: GoogleFonts.dmSans(fontSize: 16),
                      ),
                      Expanded(
                        child: Text(
                          startDate != null
                              ? '${startDate!.toLocal()}'.split(' ')[0]
                              : 'Not selected',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color:
                                startDate != null ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // End Date
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(Duration(days: 27)),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => endDate = picked);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        'Select End Date: ',
                        style: GoogleFonts.dmSans(fontSize: 16),
                      ),
                      Expanded(
                        child: Text(
                          endDate != null
                              ? '${endDate!.toLocal()}'.split(' ')[0]
                              : 'Not selected',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: endDate != null ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signin');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.black, // background hitam penuh
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: saveData,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
