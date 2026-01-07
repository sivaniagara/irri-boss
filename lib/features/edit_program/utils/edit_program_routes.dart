import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/pages/edit_program_page.dart';

import '../../../core/di/injection.dart' as di;


class EditProgramRoutes {
  static const String program = "/program";
}

final editProgramGoRoutes = [
  GoRoute(
      path: EditProgramRoutes.program,
      builder: (context, state) {
        return EditProgramPage();
      },
      routes: [
      ]
  ),
];