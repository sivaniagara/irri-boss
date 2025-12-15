import 'package:flutter_bloc/flutter_bloc.dart';
import 'faultmsg_bloc_event.dart';
import 'faultmsg_bloc_state.dart';
import '../../domain/usecases/faultmsg_params.dart';

class faultmsgBloc extends Bloc<FaultMsgEvent, faultmsgState> {
  final FetchfaultmsgMessages fetchfaultmsgMessages;

  faultmsgBloc({required this.fetchfaultmsgMessages})
      : super(faultmsgInitial()) {
    on<LoadFaultMsgEvent>(_onLoadMessages);
  }


  Future<void> _onLoadMessages(
      LoadFaultMsgEvent event, Emitter<faultmsgState> emit) async {
    emit(faultmsgLoading());
    try {
      // Call the use case with parameters from the event
      final result = await fetchfaultmsgMessages.call(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
       );

      // result is faultmsgEntity, now we can access .data
      emit(faultmsgLoaded(result.data));
    } catch (e) {
      emit(faultmsgError(e.toString()));
    }
  }

}
