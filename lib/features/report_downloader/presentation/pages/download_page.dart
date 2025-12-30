import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/report_bloc.dart';

class ReportDownloadPage extends StatelessWidget {
  final String title;
  final String url;

  const ReportDownloadPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReportDownloadBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bloc.download(title, url);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Download Report")),
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
                return Text("Error: ${state.error}");

              default:
                return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
