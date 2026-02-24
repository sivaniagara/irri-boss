import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/utils/common_date_picker.dart';
import '../bloc/date_tab_cubit.dart';
import '../bloc/power_bloc.dart';
import '../bloc/power_bloc_event.dart';
import '../bloc/power_bloc_state.dart';

class DateTabs extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;

  const DateTabs({
    super.key,
    required this.userId,
    required this.subuserId,
    required this.controllerId,
  });
   static final DateFormat apiFormat = DateFormat('yyyy-MM-dd');
   @override
  Widget build(BuildContext context) {
    return BlocBuilder<DateTabCubit, DateTabType>(
      builder: (context, selectedTab) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
               child: Column(
                children: [
                   Row(
                    children: [
                      _tab("Days", selectedTab == DateTabType.days, () {
                        context.read<DateTabCubit>().selectDays();
                        final today = apiFormat.format(DateTime.now());
                        context.read<PowerGraphBloc>().add(
                          FetchPowerGraphEvent(
                            userId: userId,
                            subuserId: subuserId,
                            controllerId: controllerId,
                            fromDate: today,
                            toDate: today,
                            sum: 0,
                          ),
                        );
                      }),

                      _tab("Weekly", selectedTab == DateTabType.weekly, () {
                        context.read<DateTabCubit>().selectWeekly();
                        final to = DateTime.now();
                        final from = to.subtract(const Duration(days: 6));
                        context.read<PowerGraphBloc>().add(
                          FetchPowerGraphEvent(
                            userId: userId,
                            subuserId: subuserId,
                            controllerId: controllerId,
                            fromDate: apiFormat.format(from),
                            toDate: apiFormat.format(to),
                            sum: 1,
                          ),
                        );
                      }),

                      _tab("Monthly", selectedTab == DateTabType.monthly, () {
                        context.read<DateTabCubit>().selectMonthly();
                        final to = DateTime.now();
                        final from = to.subtract(const Duration(days: 30));
                        context.read<PowerGraphBloc>().add(
                          FetchPowerGraphEvent(
                            userId: userId,
                            subuserId: subuserId,
                            controllerId: controllerId,
                            fromDate: apiFormat.format(from),
                            toDate: apiFormat.format(to),
                            sum: 1,
                          ),
                        );
                      }),

                      IconButton(
                        icon: const Icon(Icons.calendar_today,color: Colors.blue,),
                        onPressed: () async {
                          final result = await pickReportDate(
                            context: context,
                            allowRange: true,
                          );
                          if (result == null) return;

                          context.read<DateTabCubit>().selectDays(); // 👈 force days

                          context.read<PowerGraphBloc>().add(
                            FetchPowerGraphEvent(
                              userId: userId,
                              subuserId: subuserId,
                              controllerId: controllerId,
                              fromDate: result.fromDate,
                              toDate: result.toDate,
                              sum: 0,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  BlocBuilder<PowerGraphBloc, PowerGraphState>(
                    buildWhen: (p, c) => c is PowerGraphLoaded,
                    builder: (context, state) {
                      if (state is PowerGraphLoaded) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8, top: 6),
                          child: Center(
                            child: Text(
                              _formatRange(state.fromDate, state.toDate),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  String _formatRange(String from, String to) {
    final f = DateTime.parse(from);
    final t = DateTime.parse(to);

    if (from == to) {
      return apiFormat.format(f);
    }

    return "From: ${apiFormat.format(f)} - To: ${apiFormat.format(t)}";
  }
}
Widget _tab(String text, bool active, VoidCallback onTap) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
         height: 50,
           decoration: BoxDecoration(
            border: text != "Monthly"
                ? const Border(
              right: BorderSide(
                color: Colors.black,
                width: 0.5,
              ),
            ) : null,
           color: active ? Colors.blue : Color(0xFFD5D5D5)
         ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
