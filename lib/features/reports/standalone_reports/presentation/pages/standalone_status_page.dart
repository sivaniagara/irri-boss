import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/standalone_entities.dart';
import '../widgets/standalone_status_card.dart';


class StandaloneZoneStatusView extends StatelessWidget {
  final StandaloneEntity data;

  const StandaloneZoneStatusView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
         final allZones = data.data;
         return Column(
          children: [
              Expanded(
              child: allZones.isEmpty
                  ?  Center(
                child: Image.asset("assets/images/common/nodata.png",width: 60,height: 60,),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: allZones.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ZoneStatusCardStandAlone(data.data[index]),
                  );
                },
              ),
            ),
          ],
        );

  }
}
