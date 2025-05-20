import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lunar/components/sidebarmenu.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';
import '../controller/calendar_controller.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final ValueNotifier<DateTime> focusedDay =
      ValueNotifier<DateTime>(DateTime.now());

  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalendarController>();

    return Scaffold(
      drawer: const SidebarMenu(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 30, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.notification),
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: SizedBox(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tanggal hari ini
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: controller.formattedDay,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF45F69),
                      ),
                    ),
                    const TextSpan(text: "   "),
                    TextSpan(
                      text: controller.formattedDate,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info box prediksi
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "Your next period will start on",
                      style: GoogleFonts.dmSans(
                          fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Obx(() => Text(
                            controller.nextPeriodPrediction.value,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kalender dengan warna custom
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() {
                  return TableCalendar(
                    focusedDay: controller.focusedDay.value,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    calendarFormat: controller.calendarFormat.value,
                    selectedDayPredicate: (day) =>
                        isSameDay(controller.selectedDay.value, day),
                    onDaySelected: controller.onDaySelected,
                    eventLoader: controller.getEventsForDay,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFFFCCCF),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(color: Colors.red),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: Colors.black),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: Colors.black),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return null;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.map<Widget>((event) {
                            final type = (event as Map<String, dynamic>)['type']
                                as String;

                            // Pilih warna berdasarkan tipe
                            Color dotColor;
                            switch (type) {
                              case 'start':
                                dotColor = Colors.pink;
                                break;
                              case 'end':
                                dotColor = Colors.blue;
                                break;
                              case 'predicted_start':
                                dotColor = Colors.red.shade400;
                                break;
                              case 'predicted_end':
                                dotColor =
                                    const Color.fromARGB(255, 80, 107, 239);
                                break;
                              default:
                                dotColor = Colors.grey;
                            }

                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Event List
              Obx(() {
                final events = controller.getEventsForDay(
                  controller.selectedDay.value ?? DateTime.now(),
                );

                if (events.isEmpty) {
                  return const Text("No events for this day.");
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: events.map((event) {
                    final eventType = event['type'];
                    final eventNotes = event['notes'];

                    // Declare variables without defaults
                    Color iconColor;
                    Color eventColor;
                    IconData icon;

                    // Menentukan warna dan icon berdasarkan tipe event
                    if (eventType == 'start' ||
                        eventType == 'predicted_start') {
                      icon = Icons.play_circle_fill;
                      iconColor = Colors.pink;
                      eventColor = Color.fromARGB(255, 248, 213, 215);
                    } else if (eventType == 'end' ||
                        eventType == 'predicted_end') {
                      icon = Icons.stop_circle;
                      iconColor = Colors.blue;
                      eventColor = Color.fromARGB(255, 248, 213, 215);
                    } else if (eventType == 'noteOnly') {
                      icon = Icons.article_rounded;
                      iconColor = Colors.grey;
                      eventColor = Color.fromARGB(255, 248, 213, 215);
                    } else {
                      return Container(); // If the event type does not match, return an empty container.
                    }

                    // Add shadow for all event types
                    BoxShadow boxShadow = BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    );

                    return Container(
                      decoration: BoxDecoration(
                        color: eventColor,
                        border:
                            Border.all(color: Colors.red.shade200, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [boxShadow], // Apply shadow to all events
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          icon,
                          color: iconColor,
                        ),
                        title: Text(
                          eventType?.toUpperCase() ?? "UNKNOWN",
                          style:
                              GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(eventNotes ?? "No notes"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await controller
                                .removeNote(controller.selectedDay.value!);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 16),

              // Tombol Tambah Event
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final selectedDate = controller.selectedDay.value;

                    if (selectedDate == null) {
                      Get.snackbar(
                        'No date selected',
                        'Please select a date first.',
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        colorText: Colors.white,
                      );
                      return;
                    }

                    final sel = controller.selectedDay.value!;
                    final monthKey =
                        "${sel.year}-${sel.month.toString().padLeft(2, '0')}";

                    DateTime? localStartDate = controller.startDates[monthKey];

                    String? selectedStart = (localStartDate != null &&
                            sel.isAtSameMomentAs(localStartDate))
                        ? 'yes'
                        : null;

                    // Ensure startDate is not null before using it
                    if (localStartDate == null ||
                        selectedDate.isBefore(localStartDate) ||
                        selectedDate.isAtSameMomentAs(localStartDate)) {
                      // If start date is not set or selected date is before start date, show the "Is this the Start?" bottom sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                          20,
                                  top: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Add Event for ${DateFormat('MMMM d, y').format(selectedDate.toLocal())}",
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text("Is this the start?"),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: 'yes',
                                          groupValue: selectedStart,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedStart = value;
                                              if (selectedStart == 'yes') {
                                                localStartDate = selectedDate;
                                                controller.startDate.value =
                                                    localStartDate;
                                              }
                                            });
                                          },
                                        ),
                                        const Text("Yes"),
                                        const SizedBox(width: 20),
                                        Radio<String>(
                                          value: 'no',
                                          groupValue: selectedStart,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedStart = value;
                                            });
                                          },
                                        ),
                                        const Text("No"),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: noteController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        hintText: "Add notes...",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (selectedStart == null) {
                                          Get.snackbar(
                                            "Missing Info",
                                            "Please select Start or No",
                                            backgroundColor: Colors.redAccent,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        final note = noteController.text;

                                        // Jika 'yes' dipilih, tandai tanggal tersebut sebagai start date
                                        if (selectedStart == 'yes') {
                                          controller.markStartEndPeriod(
                                              selectedDate,
                                              note: note);
                                        }
                                        // Jika 'no' dipilih, reset tanggal event dan hapus di Firestore
                                        else if (selectedStart == 'no') {
                                          controller.startDate.value =
                                              null; // Reset start date di tampilan

                                          // Reset startDate dan endDate di Firestore
                                          controller.removeEventAndNotes(
                                              selectedDate);
                                        }

                                        Navigator.pop(
                                            context); // Menutup bottom sheet setelah memilih
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFF45F69),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        "Save Event",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else if (selectedDate.isAfter(localStartDate) &&
                        selectedDate.month == localStartDate.month &&
                        selectedDate.year == localStartDate.year) {
                      // If the selected date is after the start date, show the "Is this the End?" bottom sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) {
                          String? selectedEnd =
                              (controller.endDate.value != null &&
                                      selectedDate.isAtSameMomentAs(
                                          controller.endDate.value!))
                                  ? 'yes'
                                  : null;
                          String? localSelectedEnd =
                              selectedEnd; // Salin dulu ke variabel lokal

                          return StatefulBuilder(
                            builder: (context, setModalState) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                          20,
                                  top: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Add End Event for ${DateFormat('MMMM d, y').format(selectedDate.toLocal())}",
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text("Is this the end?"),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: 'yes',
                                          groupValue: localSelectedEnd,
                                          onChanged: (value) {
                                            setModalState(() {
                                              localSelectedEnd = value;
                                            });
                                          },
                                        ),
                                        const Text("Yes"),
                                        const SizedBox(width: 20),
                                        Radio<String>(
                                          value: 'no',
                                          groupValue: localSelectedEnd,
                                          onChanged: (value) {
                                            setModalState(() {
                                              localSelectedEnd = value;
                                            });
                                          },
                                        ),
                                        const Text("No"),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: noteController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        hintText: "Add notes...",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        final note = noteController.text;

                                        if (localSelectedEnd == 'yes') {
                                          controller.addEvent(
                                              selectedDate, 'end',
                                              note: note);
                                        } else {
                                          controller.addEvent(
                                              selectedDate, 'noteOnly',
                                              note: note);
                                        }

                                        selectedEnd =
                                            localSelectedEnd; // Simpan balik ke variabel utama
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFF45F69),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        "Save Event",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                  icon: const Icon(Icons.add, color: Color(0xFFF45F69)),
                  label: Text(
                    "Track your period",
                    style:
                        GoogleFonts.dmSans(fontSize: 16, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFFFCCCF)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
