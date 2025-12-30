
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
 import 'package:share_plus/share_plus.dart';

import '../../domain/usecase/download_report_excel.dart';

enum DownloadStatus { idle, loading, success, error }

class ReportDownloadState {
  final DownloadStatus status;
  final String? filePath;
  final String? error;

  const ReportDownloadState({
    this.status = DownloadStatus.idle,
    this.filePath,
    this.error,
  });

  ReportDownloadState copyWith({
    DownloadStatus? status,
    String? filePath,
    String? error,
  }) {
    return ReportDownloadState(
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
    );
  }
}

class ReportDownloadBloc extends Cubit<ReportDownloadState> {
  final DownloadReportExcel usecase;

  ReportDownloadBloc(this.usecase)
      : super(const ReportDownloadState());

  Future<void> download(String title, String url) async {
    emit(state.copyWith(status: DownloadStatus.loading));
    try {
      final path = await usecase(
        reportTitle: title,
        url: url,
      );
      emit(state.copyWith(
          status: DownloadStatus.success, filePath: path));
    } catch (e) {
      emit(state.copyWith(
          status: DownloadStatus.error, error: e.toString()));
    }
  }

  Future<void> openFile() async {
    if (state.filePath != null) {
      await OpenFilex.open(state.filePath!);
       // OpenFile.open(state.filePath!);
    }
  }


  void shareFile() async {
    if (state.filePath != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(state.filePath!)],
        ),
      );
    }
  }
}
