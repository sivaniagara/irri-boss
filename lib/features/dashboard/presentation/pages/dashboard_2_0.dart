import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../../core/utils/app_images.dart';
import '../widgets/static_progress_circle_with_image.dart';

class Dashboard20 extends StatefulWidget {
  const Dashboard20({super.key});

  @override
  State<Dashboard20> createState() => _Dashboard20State();
}

class _Dashboard20State extends State<Dashboard20> {
  int bottomSheetIndex = 0;


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 20,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    AppImages.mountain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 20,
                    children: [
                      Row(
                        spacing: 5,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.signal_cellular_alt, color: Colors.green),
                              Text(
                                'Good Signal',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.battery_6_bar_rounded, color: Colors.green),
                              Text(
                                'Battery 95% | 17/Dec/2025',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.circle, color: Colors.green),
                              Text(
                                'Live Sync At : 17/11/2025, 12:26:59',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.cloudy_snowing, color: Theme.of(context).colorScheme.primary),
                              Text(
                                overflow: TextOverflow.ellipsis,
                                "25\u00B0 C, Windy",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
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
          dashboardCard(
            child: Column(
              spacing: 20,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Image.asset(
                      'assets/images/common/motor_g.png',
                      width: 50,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            Text(
                              'Motor',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(width: 2, color: Colors.green),
                              ),
                              child: Image.asset(
                                'assets/images/icons/switch_on_icon.png',
                                width: 20,
                              ),
                            )
                          ],
                        ),
                        Text('Cyclic Timer', style: Theme.of(context).textTheme.bodySmall)
                      ],
                    ),
                    const Spacer(),
                    Row(
                      spacing: 10,
                      children: [
                        Image.asset(
                          'assets/images/icons/pressure_gauge_icon.png',
                          width: 30,
                        ),
                        Column(
                          spacing: 5,
                          children: [
                            Text('Pressure', style: Theme.of(context).textTheme.labelLarge),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "In: ",
                                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '2.0   ',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "Out: ",
                                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '2.0',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    scheduleTimeCard(
                      title: 'Set Time',
                      value: '12:10:00',
                      titleColor: const Color(0xff2E712A),
                      backgroundColor: const Color(0xff689F39),
                    ),
                    scheduleTimeCard(
                      title: 'Time Left',
                      value: '02:10:00 ',
                      titleColor: const Color(0xff347CA6),
                      backgroundColor: const Color(0xff52AED7),
                    ),
                    Image.asset(
                      'assets/images/common/valve_with_flow.png',
                      width: 70,
                    )
                  ],
                )
              ],
            ),
          ),
          dashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                iconWithHeader(
                  title: 'Water Level',
                  iconBackgroundColor: const Color(0xffB4E7FF),
                  iconColor: Theme.of(context).colorScheme.primary,
                  icon: Icon(Icons.cloudy_snowing, color: Theme.of(context).colorScheme.primary),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/common/water_level.png',
                      width: 80,
                    ),
                    moonCard(
                      moonColor: const Color(0xffD4EAFF),
                      skyColor: const Color(0xffE6F7FF),
                      title: 'Max Level',
                      value: '12.79 Feet',
                    ),
                    moonCard(
                      moonColor: const Color(0xffD4EAFF),
                      skyColor: const Color(0xffE6F7FF),
                      title: 'Current Level',
                      value: '63%',
                    ),
                  ],
                )
              ],
            ),
          ),
          dashboardCard(
            child: Column(
              spacing: 20,
              children: [
                Row(
                  children: [
                    iconWithHeader(
                      title: 'Program',
                      subTitle: '12:31 PM',
                      iconBackgroundColor: const Color(0xffB1E4AA),
                      iconColor: Theme.of(context).colorScheme.primary,
                      icon: Image.asset(
                        'assets/images/icons/program_icon.png',
                        width: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xff0F8AD0)),
                        color: const Color(0xffE6F7FF),
                      ),
                      child: const Row(
                        children: [
                          Text('BLOCK 001', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                          Icon(Icons.keyboard_arrow_down, color: Colors.black)
                        ],
                      ),
                    )
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 25,
                    children: [
                      ...List.generate(6, (index) {
                        return Column(
                          spacing: 10,
                          children: [
                            StaticProgressCircleWithImage(
                              progress: 0.68,
                              size: 70,
                              progressColor: Theme.of(context).colorScheme.primary,
                              backgroundColor: Colors.grey.shade300,
                              strokeWidth: 5,
                              edgeIcon: Icons.bolt,
                              iconColor: Theme.of(context).colorScheme.primary,
                              iconSize: 15,
                              centerWidget: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset('assets/images/common/sprinkler.png'),
                              ),
                            ),
                            Text(
                              'P${index + 1} (Aarnav)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Image.asset('assets/images/icons/switch_on_icon.png')
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }

  Widget iconWithHeader({
    required String title,
    String? subTitle,
    required Color iconBackgroundColor,
    required Color iconColor,
    required Widget icon,
  }) {
    return Row(
      spacing: 10,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: iconBackgroundColor,
          ),
          child: icon,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            if (subTitle != null) Text(subTitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        )
      ],
    );
  }

  Widget scheduleTimeCard({
    required String title,
    required String value,
    required Color titleColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: 110,
      height: 80,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(9)),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
              color: titleColor,
            ),
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          Center(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  Widget moonCard({
    required Color moonColor,
    required Color skyColor,
    required String title,
    required String value,
  }) {
    return Container(
      width: 110,
      height: 80,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: moonColor),
      child: Stack(
        children: [
          Positioned(
            left: -130,
            top: -120,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: skyColor,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black45),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget dashboardCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            left: (MediaQuery.of(context).size.width / 5) * currentIndex + (MediaQuery.of(context).size.width / 10) - 35,
            top: -15,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: _getIcon(currentIndex, true),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Home'),
              _buildNavItem(1, 'Report'),
              _buildNavItem(2, 'Settings'),
              _buildNavItem(3, 'Message'),
              _buildNavItem(4, 'Profile'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (!isSelected) _getIcon(index, false),
            if (isSelected) const SizedBox(height: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0F8AD0) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIcon(int index, bool isSelected) {
    final color = isSelected ? const Color(0xFF0F8AD0) : Colors.grey;
    switch (index) {
      case 0:
        return Icon(Icons.home_outlined, color: color, size: 28);
      case 1:
        return Icon(Icons.bar_chart_outlined, color: color, size: 28);
      case 2:
        return Icon(Icons.settings_outlined, color: color, size: 28);
      case 3:
        return Icon(Icons.near_me_outlined, color: color, size: 28);
      case 4:
        return Icon(Icons.person_outline, color: color, size: 28);
      default:
        return Icon(Icons.home_outlined, color: color, size: 28);
    }
  }
}
