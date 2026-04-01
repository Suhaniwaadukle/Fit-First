import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/controllers/body_iq_controller.dart';

class ProgressTrackerScreen extends ConsumerStatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  ConsumerState<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends ConsumerState<ProgressTrackerScreen> {
  String? selectedMood;
  String? selectedEmotion;
  List<String> selectedTriggers = [];

  final List<String> moodOptions = ['Great', 'Good', 'Neutral', 'Bad', 'Stressed', 'Angry', 'Anxious'];
  final List<String> triggers = ['Work', 'Family', 'Sleep', 'Food', 'Finances', 'Overthinking'];
  final List<String> emotionOptions = ['Calm', 'Energized', 'Exhausted', 'Scared', 'Motivated', 'Lonely'];

  @override
  Widget build(BuildContext context) {
    final bodyIqProvider = ref.watch(DiProviders.bodyIqControllerProvider.notifier);
    return Scaffold(
      appBar: CommonAppBar(),
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              TabBar(
                dividerColor: AppColors.kBlack.withValues(alpha: 0.1),
                tabs: [
                  Tab(text: 'Progress'),
                  Tab(text: 'Mood Tracker'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    buildProgressTab(context, bodyIqProvider),
                    buildMoodTrackerTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProgressTab(BuildContext context, BodyIqController bodyIqProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Weight Progress
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('⚖️', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 12),
                          Text('Weight Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 150,
                        child: CustomPaint(painter: LineChartPainter(), size: Size.infinite),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Week 1', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Week 2', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Week 3', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Week 4', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Daily Steps
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('📊', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 12),
                          Text('Daily Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 150,
                        child: CustomPaint(painter: BarChartPainter(), size: Size.infinite),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Mon', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Tue', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Wed', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Thu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Fri', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Sat', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Sun', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Food Habits Score
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('🥗', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 12),
                          Text(
                            'Food Habits Score',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: 0.7,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation(Color(0xFF10B981)),
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: Text(
                                    '70%',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(child: Text('Good progress! Keep it up.', style: TextStyle(color: Colors.grey))),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Mood & Stress
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('❤️', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 12),
                          Text('Mood & Stress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text('Today\'s Mood', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Spacer(),
                            Text('😊', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text(
                              'Good',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text('Stress Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Spacer(),
                            Container(
                              width: 100,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Low',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text('Sleep Quality', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Spacer(),
                            Row(
                              children: [
                                Icon(Icons.star, color: Color(0xFF8B5CF6), size: 20),
                                Icon(Icons.star, color: Color(0xFF8B5CF6), size: 20),
                                Icon(Icons.star, color: Color(0xFF8B5CF6), size: 20),
                                Icon(Icons.star, color: Color(0xFF8B5CF6), size: 20),
                                Icon(Icons.star_border, color: Color(0xFF8B5CF6), size: 20),
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
          ),
          SizedBox(height: 16),
          // Button
        ],
      ),
    );
  }

  Widget buildMoodTrackerTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('How do you feel today?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: moodOptions.map((mood) {
              final isSelected = selectedMood == mood;
              return ChoiceChip(
                showCheckmark: false,
                label: Text(
                  mood,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isSelected ? AppColors.kWhite : AppColors.kBlack,
                      ),
                ),
                selected: isSelected,
                selectedColor: AppColors.kPrimaryColor,
                onSelected: (_) {
                  setState(() => selectedMood = mood);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('What triggered your mood today?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: triggers.map((trigger) {
              final isSelected = selectedTriggers.contains(trigger);
              return FilterChip(
                showCheckmark: false,
                label: Text(
                  trigger,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isSelected ? AppColors.kWhite : AppColors.kBlack,
                      ),
                ),
                selected: isSelected,
                selectedColor: AppColors.kPrimaryColor,
                onSelected: (_) {
                  setState(() {
                    if (isSelected) {
                      selectedTriggers.remove(trigger);
                    } else {
                      selectedTriggers.add(trigger);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Top Emotion Today?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: emotionOptions.map((emotion) {
              final isSelected = selectedEmotion == emotion;
              return ChoiceChip(
                showCheckmark: false,
                label: Text(
                  emotion,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isSelected ? AppColors.kWhite : AppColors.kBlack,
                      ),
                ),
                selected: isSelected,
                selectedColor: AppColors.kPrimaryColor,
                onSelected: (_) {
                  setState(() => selectedEmotion = emotion);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          ButtonWidget(
            text: "Submit Mood Tracking",
            borderRadius: BorderRadius.circular(15),
            backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.kWhite,
                  fontWeight: FontWeight.bold,
                ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF7C3AED)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.9, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = Color(0xFF7C3AED)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 10;
    final heights = [0.7, 0.6, 0.8, 0.5, 0.9, 1.0, 0.7];

    for (int i = 0; i < heights.length; i++) {
      final x = (i + 1) * barWidth;
      final height = size.height * heights[i];
      final rect = Rect.fromLTWH(x, size.height - height, barWidth * 0.6, height);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(4)), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
