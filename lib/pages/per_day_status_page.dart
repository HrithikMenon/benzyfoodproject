import 'package:benzyproject/features/services/employee_order_details.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PerDayStatusPage extends StatelessWidget {
  PerDayStatusPage(
      {super.key,
      required this.month,
      required this.dayIndex,
      required this.day});

  final EmployeeOrderService empService = EmployeeOrderService();
  int month;
  int dayIndex;
  String day;

  int fineAmount = 100;
  int totalFine = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(day),
          ),
          body: FutureBuilder<Map<String, dynamic>>(
            future: empService.getOrderDetails(month),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !(snapshot.data?.isNotEmpty ?? false)) {
                return const Center(child: Text('Something went wrong'));
              }

              final snap = snapshot.data;
              final reports = snap?['reports'] as List<dynamic>?;

              final dayData = reports![dayIndex] as Map<String, dynamic>?;

              final optIns = dayData?['opt_ins'];

              if (optIns is List && optIns.isEmpty) {
                return const Center(child: Text('Data is empty'));
              }

              if (optIns is Map<String, dynamic>) {
                int totalFine = 0;
                int fineAmount = 100;

                optIns.forEach((key, value) {
                  if (value == 'Pending') {
                    totalFine += fineAmount;
                  }
                });

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fine for this day: Rs.$totalFine',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: optIns.length,
                          itemBuilder: (context, index) {
                            String key = optIns.keys.elementAt(index);
                            return ListTile(
                              title: Text(key),
                              subtitle: Text(optIns[key]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Unexpected data format'));
            },
          )),
    );
  }
}
