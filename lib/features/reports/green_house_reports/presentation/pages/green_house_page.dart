import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lottie/lottie.dart';

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
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));

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

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFE5F1F1),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "GREEN HOUSE REPORTS",
            style: TextStyle(fontSize : 20 ,color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: const BackButton(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined, color: Colors.black),
              onPressed: () async {
                final result = await pickReportDate(
                  context: context,
                  allowRange: true,
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/No_data_current.json',
                width: 220,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}