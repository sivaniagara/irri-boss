import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/custom_card.dart';

class Dashboard20 extends StatefulWidget {
  const Dashboard20({super.key});

  @override
  State<Dashboard20> createState() => _Dashboard20State();
}

class _Dashboard20State extends State<Dashboard20> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                Positioned(
                    bottom: -10,
                    right: -10,
                    child: Image.asset(
                        height: 80,
                        'assets/images/common/mountain.png'
                    )
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 20,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              Icon(Icons.signal_cellular_alt, color: Colors.green,),
                              Text('Good Signal', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),),
                            ],
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Icon(Icons.battery_6_bar_rounded, color: Colors.green,),
                              Text('Battery 95%  |  17/Dec/2025', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),),
                            ],
                          )


                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              Icon(Icons.circle, color: Colors.green,),
                              Text('Live Sync At : 17/11/2025, 12:26:59', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Icon(Icons.cloudy_snowing, color: Theme.of(context).colorScheme.primary,),
                              Text("25\u00B0 C, Windy", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),),
                            ],
                          ),


                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
