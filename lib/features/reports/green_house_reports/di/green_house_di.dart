import '../../../../core/di/injection.dart';
import '../presentation/bloc/green_house_bloc.dart';

void initGreenHouse() {
  /// 🔹 Bloc (No DataSource / Repository / UseCase needed)
  sl.registerFactory(
        () => GreenHouseBloc(),
  );
}