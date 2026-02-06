import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../core/utils/common_date_picker.dart';
import '../bloc/green_house_bloc.dart';
import '../bloc/green_house_bloc_event.dart';
import '../bloc/green_house_bloc_state.dart';



class GreenHousePage extends StatefulWidget {
  final int userId;
  final int subuserId;
  final int controllerId;

  const GreenHousePage({
    super.key,
    required this.userId,
    required this.subuserId,
    required this.controllerId,
  });

  @override
  State<GreenHousePage> createState() => _GreenHousePageState();
}

class _GreenHousePageState extends State<GreenHousePage> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    /// 🔹 Load today report initially
    final today = DateTime.now();
    final formattedDate =
        "${today.year.toString().padLeft(4, '0')}-"
        "${today.month.toString().padLeft(2, '0')}-"
        "${today.day.toString().padLeft(2, '0')}";

    context.read<GreenHouseBloc>().add(
      FetchGreenHouseReportEvent(
        userId: widget.userId,
        subuserId: widget.subuserId,
        controllerId: widget.controllerId,
        fromDate: formattedDate,
        toDate: formattedDate,
      ),
    );
  }

  Future<void> _launchExternalUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        appBar: AppBar(
          // 🔹 TITLE
          title: const Text("GREEN HOUSE REPORT"),
          actions: [
            // 🔹 DATE PICKER
            IconButton(
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.black,
              ),
              onPressed: () async {
                final result = await pickReportDate(
                  context: context,
                  allowRange: false,
                );
      
                if (result == null) return;
      
                context.read<GreenHouseBloc>().add(
                  FetchGreenHouseReportEvent(
                    userId: widget.userId,
                    subuserId: widget.subuserId,
                    controllerId: widget.controllerId,
                    fromDate: result.fromDate,
                    toDate: result.toDate,
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<GreenHouseBloc, GreenHouseState>(
          listener: (context, state) {
            if (state is GreenHouseLoaded) {
              print('url:${state.url}');
              _webViewController.loadRequest(Uri.parse('https://3.1.62.165:8086/report/2558/0/27910/2026-01-06/2026-01-06/greenhouseruntime'));
            }
          },
          builder: (context, state) {
            if (state is GreenHouseLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
      
            if (state is GreenHouseError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
      
            if (state is GreenHouseLoaded) {
              return Column(
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _launchExternalUrl(Uri.parse(state.url)),
                      child: Text('Green House Reports'),
                    ),
                  ),
                  Expanded(child: WebViewWidget(controller: _webViewController)),
                ],
              );
            }
      
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
