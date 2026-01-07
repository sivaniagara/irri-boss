import 'core/flavor/flavor_config.dart';
import 'app.dart';

Future<void> main() async {
  FlavorConfig.setup(Flavor.irriBossProduction);
  await appMain();
}