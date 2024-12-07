import 'dart:developer';

import 'package:benzyproject/features/services/employee_order_details.dart';
import 'package:benzyproject/pages/per_day_status_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class OrderDetailsPage extends StatelessWidget {
  OrderDetailsPage({super.key, required this.month});

  final int month;
  final EmployeeOrderService empService = EmployeeOrderService();

  String formattedDate = '';
  Map<String, dynamic> perDayStats = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Food Order Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: empService.getOrderDetails(month),
            builder: (context, snapshot) {
              log(snapshot.data.toString());

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text('Something went wrong'));
              }

              final snap = snapshot.data;
              final user = snap?['user'];
              final reports = snap?['reports'] ?? [];

              if (user == null || reports.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              int fineAmount = 100;
              int totalFine = 0;

              for (var report in snapshot.data!['reports'] ?? []) {
                var opt = report['opt_ins'];
                if (opt is Map<String, dynamic>) {
                  opt.forEach((key, value) {
                    if (value == 'Pending') {
                      totalFine = totalFine + fineAmount;
                    }
                  });

                  log(totalFine.toString());
                }
              }

              return Column(
                children: [
                  Text(
                    'Employee Name : ${user['f_name'] ?? ''} ${user['l_name'] ?? ''}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  Text('Total fine for this month : Rs. $totalFine',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        final date = report['date'];

                        String formattedDate = 'Invalid date';
                        if (date != null) {
                          try {
                            List<String> parts = date.split('-');
                            String normalizedDate =
                                '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
                            DateTime parsedDate =
                                DateTime.parse(normalizedDate);
                            formattedDate =
                                DateFormat('MMMM d, yyyy').format(parsedDate);
                          } catch (e) {
                            log(e.toString());
                          }
                        }

                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PerDayStatusPage(
                                  month: month,
                                  dayIndex: index,
                                  day: formattedDate,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
