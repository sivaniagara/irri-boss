import 'package:flutter/material.dart';

class EditProgramPage extends StatelessWidget {
  const EditProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Program 1'),
        actions: [
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Image.asset('assets/images/icons/sent_and_receive_icon.png'),
            ),

          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Select Zone',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 28, color: Colors.black,),
                    const Spacer(),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.touch_app_outlined,
                      color: Colors.lightBlue[50]!,
                        iconName: 'add_icon'
                    ),
                    const SizedBox(width: 12),
                    // Delete Button
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      color: Colors.red[50]!,
                        iconName: 'delete_icon'
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Horizontal Scrollable Zone Chips
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: zones.asMap().entries.map((entry) {
                //       int index = entry.key;
                //       String zone = entry.value;
                //
                //       bool isSelected = index == selectedIndex;
                //
                //       return GestureDetector(
                //         onTap: () {
                //           setState(() {
                //             selectedIndex = index;
                //           });
                //         },
                //         child: Container(
                //           margin: const EdgeInsets.only(right: 12),
                //           padding: const EdgeInsets.symmetric(
                //             horizontal: 24,
                //             vertical: 12,
                //           ),
                //           decoration: BoxDecoration(
                //             color: isSelected
                //                 ? Colors.blue[400]
                //                 : Colors.blue[50],
                //             borderRadius: BorderRadius.circular(30),
                //             border: Border.all(
                //               color: isSelected
                //                   ? Colors.blue[400]!
                //                   : Colors.grey[300]!,
                //               width: 1.5,
                //             ),
                //           ),
                //           child: Text(
                //             zone,
                //             style: TextStyle(
                //               color: isSelected ? Colors.white : Colors.black87,
                //               fontWeight: FontWeight.w600,
                //               fontSize: 16,
                //             ),
                //           ),
                //         ),
                //       );
                //     }).toList(),
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String iconName,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Image.asset(
          'assets/images/icons/$iconName.png',
        width: 20,
      ),
    );
  }
}
