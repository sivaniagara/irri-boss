# Show On Delay Timer on Motor Image

This plan implements a feature to display the "On Delay Timer" over the motor image on the dashboard when the motor is ON and a delay is set.

## User Review Required

> [!NOTE]
> The "On Delay Timer" will be extracted from the `liveDisplay1` field (which corresponds to index 3 in the `cM` string of the hardware payload). It will be shown only when the motor is ON (`motorOnOff == '1'`) and the timer value is not `00:00:00`.

## Proposed Changes

### Dashboard Feature

#### [MODIFY] [livemessage_entity.dart](file:///C:/Users/rahul/irri-boss/lib/features/dashboard/domain/entities/livemessage_entity.dart)
- Add `onDelayTimer` field to `LiveMessageEntity`.
- Update constructor, `props`, and `copyWith`.

#### [MODIFY] [live_message_model.dart](file:///C:/Users/rahul/irri-boss/lib/features/dashboard/data/models/live_message_model.dart)
- Parse `onDelayTimer` from the `cM` message in `fromLiveMessage`.
- Extract the timer value if the string contains `ONDEL`.

#### [MODIFY] [dashboard_2_0.dart](file:///C:/Users/rahul/irri-boss/lib/features/dashboard/presentation/pages/dashboard_2_0.dart)
- Wrap the motor image in a `Stack`.
- Display the `onDelayTimer` as an overlay if it's active.

#### [MODIFY] [controller_live_page.dart](file:///C:/Users/rahul/irri-boss/lib/features/dashboard/presentation/pages/controller_live_page.dart)
- Update `_buildEnhancedMotorWidget` to display the `onDelayTimer` overlay.

## Verification Plan

### Manual Verification
- Provide a mock payload with `motorOnOff` as `1` and `ONDEL = 00:01:30` in the `cM` string.
- Verify that the timer `00:01:30` appears on the motor image.
- Verify that if `ONDEL = 00:00:00` or the motor is OFF, the timer is hidden.
