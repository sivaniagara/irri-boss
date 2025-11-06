import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreviousDaySection extends StatelessWidget {

  // ✅ Each parameter has its own today/previous values
  final String runTimeToday;
  final String runTimePrevious;
  final String flowToday;
  final String flowPrevious;
  final String cFlowToday;
  final String cFlowPrevious;

  const PreviousDaySection({
    super.key,
     required this.runTimeToday,
    required this.runTimePrevious,
    required this.flowToday,
    required this.flowPrevious,
    required this.cFlowToday,
    required this.cFlowPrevious,
  });

  Widget _buildValueBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  TableRow _buildRow(String label, String today, String previous) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      Padding(padding: const EdgeInsets.all(4.0), child: _buildValueBox(today)),
      Padding(padding: const EdgeInsets.all(4.0), child: _buildValueBox(previous)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade700.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [

          // ✅ Data Table
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FlexColumnWidth(2.5), // Parameter
              1: FlexColumnWidth(2),   // Today
              2: FlexColumnWidth(2),   // Previous
            },
            children: [
              // Header Row
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      "",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      "Today",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      "Previous Day",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Divider
              TableRow(
                children: [
                  Container(height: 1, color: Colors.white30),
                  Container(height: 1, color: Colors.white30),
                  Container(height: 1, color: Colors.white30),
                ],
              ),

              // ✅ Individual Rows
              _buildRow("Run Time", runTimeToday, runTimePrevious),
              _buildRow("Flow", flowToday, flowPrevious),
              _buildRow("C. Flow", cFlowToday, cFlowPrevious),
            ],
          ),
        ],
      ),
    );
  }
}
