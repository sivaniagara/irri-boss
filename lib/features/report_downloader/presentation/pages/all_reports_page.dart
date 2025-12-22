import 'package:flutter/material.dart';
import 'download_page.dart';

class AllReportsPage extends StatelessWidget {
  const AllReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Reports")),
      body: ListTile(
        title: const Text("Power & Motor Report"),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>  ReportDownloadPage(title: "Power & Motor Report", url: "http://3.1.62.165:8080/api/v1/user/2558/subuser/0/controller/27910/powerandmotor"
            "?fromDate='2025-12-15'&toDate='2025-12-17'&sum=0"),
              ),
            );
          },
        ),
      ),
    );
  }
}
