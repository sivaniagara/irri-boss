import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/no_data.dart';

import '../../../../core/flavor/flavor_config.dart';
import '../../../../core/services/api_client.dart';
import '../bloc/report_bloc.dart';

class ReportDownloadPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;


  const ReportDownloadPage({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
      final bloc = context.read<ReportDownloadBloc>();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (data.isNotEmpty) {
         // Only trigger download if there’s valid data
         bloc.download(title: title, data: data);
       } else {
         // Show a snackbar or do nothing
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("No data available to download")),
         );
       }
     });


    return GlassyWrapper(
      child: Scaffold(
        appBar: AppBar(title: const Text("Download Reports")),
        body: Center(
          child: BlocBuilder<ReportDownloadBloc, ReportDownloadState>(
            builder: (context, state) {
              switch (state.status) {
                case DownloadStatus.loading:
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Downloading..."),
                    ],
                  );
      
                case DownloadStatus.success:
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 64),
                      const SizedBox(height: 16),
                      const Text("Download Completed"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: bloc.openFile,
                        child: const Text("Open"),
                      ),
                      ElevatedButton(
                        onPressed: bloc.shareFile,
                        child: const Text("Share"),
                      ),
                    ],
                  );
      
                case DownloadStatus.error:
                  return Column(
                    children: [
                      Expanded(child: noDataNew),
                      Expanded(child: Text("Error: ${state.error}")),
                    ],
                  );
      
                default:
                  return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}
