import 'package:flutter_test/flutter_test.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/data/models/live_message_model.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/data/models/controller_model.dart';

void main() {
  group('LiveMessageModel.fromLiveMessage (LD04)', () {
    test(
        'parses double-pump payload currents from indices 8..10 (not brVoltage)',
        () {
      const message =
          '0,0,239,231,238,407,406,413,00.0,00.0,00.0,Timer Mode,0,000,00:00:00,00:03:00,0,100,100,0,0,0,0,000.0,0,000.0,0,0,123456789,49.9,000,000,100,100,100,100,100,100,0.00F-00,000.0,16,0,0,0,03:01,02:24,52,61,';

      final model = LiveMessageModel.fromLiveMessage(message,
          typeCode: 'LD04', externalLastSync: '10:08:00\n10/04/26');

      expect(model.brVoltage, '413');
      expect(model.rCurrent, '00.0');
      expect(model.yCurrent, '00.0');
      expect(model.bCurrent, '00.0');
      expect(model.modeOfOperation, 'Timer Mode');
    });

    test(
        'correctly handles single-pump data that looks like double-pump (user CM data)',
        () {
      const message =
          'cM":"0,0,239,231,238,407,406,413,00.0,00.0,00.0,Timer Mode,0,000,00:00:00,00:03:00,0,100,100,0,0,0,0,000.0,0,000.0,0,0,123456789,49.9,000,000,100,100,100,100,100,100,0.00F-00,000.0,16,0,0,0,03:01,02:24,52,61,';

      // Extract just the comma-separated part
      final cleanMessage = message.split('":"').last.replaceAll('"', '');

      final model = LiveMessageModel.fromLiveMessage(cleanMessage,
          typeCode: 'LD04', externalLastSync: '10:08:00\n10/04/26');

      // Should be parsed as single-pump, so rCurrent should be '00.0' not '413'
      expect(model.rCurrent, '00.0');
      expect(model.yCurrent, '00.0');
      expect(model.bCurrent, '00.0');
      expect(model.brVoltage, '413');
      expect(model.modeOfOperation, 'Timer Mode');
    });
  });

  group('ControllerModel.fromJson', () {
    test(
        'correctly uses LD04 parsing for double-pump controllers (modelId == 27)',
        () {
      final controllerJson = {
        'modelId': 27,
        'liveMessage':
            '0,0,239,231,238,407,406,413,00.0,00.0,00.0,Timer Mode,0,000,00:00:00,00:03:00,0,100,100,0,0,0,0,000.0,0,000.0,0,0,123456789,49.9,000,000,100,100,100,100,100,100,0.00F-00,000.0,16,0,0,0,03:01,02:24,52,61,',
        'livesyncDate': '10/04/26',
        'livesyncTime': '10:08:00',
        'userDeviceId': 12345,
        'userId': 1,
        'deviceId': 'TEST001',
        'controllerName': 'Test Controller',
        'status': '1',
        'ctrlLatestMsg': '',
        'programList': [],
      };

      final model = ControllerModel.fromJson(controllerJson);

      // Should be parsed as single-pump (LD04 with improved detection), so rCurrent should be '00.0' not '413'
      expect(model.liveMessage.rCurrent, '00.0');
      expect(model.liveMessage.yCurrent, '00.0');
      expect(model.liveMessage.bCurrent, '00.0');
      expect(model.liveMessage.brVoltage, '413');
      expect(model.liveMessage.modeOfOperation, 'Timer Mode');
    });

    test('uses standard parsing for non-double-pump controllers', () {
      final controllerJson = {
        'modelId': 1, // Not a double-pump controller
        'liveMessage':
            '0,0,239,231,238,407,406,413,00.0,00.0,00.0,Timer Mode,0,000,00:00:00,00:03:00,0,100,100,0,0,0,0,000.0,0,000.0,0,0,123456789,49.9,000,000,100,100,100,100,100,100,0.00F-00,000.0,16,0,0,0,03:01,02:24,52,61,',
        'livesyncDate': '10/04/26',
        'livesyncTime': '10:08:00',
        'userDeviceId': 12345,
        'userId': 1,
        'deviceId': 'TEST001',
        'controllerName': 'Test Controller',
        'status': '1',
        'ctrlLatestMsg': '',
        'programList': [],
      };

      final model = ControllerModel.fromJson(controllerJson);

      // Standard parsing (no typeCode) uses LD01/LD06 format where mode is at position 14
      // For this message format, position 14 is '00:00:00' (zone duration), not 'Timer Mode'
      expect(model.liveMessage.modeOfOperation, '00:00:00');
    });
  });
}
