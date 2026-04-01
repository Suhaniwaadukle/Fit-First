import 'package:flutter/material.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  // Single select
  String? selectedMood;
  String? topEmotion;

  // Multi-select
  final List<String> moodTriggers = [
    'Work',
    'Family',
    'Sleep',
    'Food',
    'Finances',
    'Overthinking',
  ];
  final Set<String> selectedTriggers = {};

  final List<String> moodOptions = [
    'Great',
    'Good',
    'Neutral',
    'Bad',
    'Stressed',
    'Angry',
    'Anxious',
  ];

  final List<String> emotionOptions = [
    'Calm',
    'Energized',
    'Exhausted',
    'Scared',
    'Motivated',
    'Lonely',
  ];

  Widget _buildSelectableChips({
    required List<String> options,
    required String? selectedValue,
    required void Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: Colors.blueAccent,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: moodTriggers.map((trigger) {
        final isSelected = selectedTriggers.contains(trigger);
        return FilterChip(
          label: Text(trigger),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedTriggers.add(trigger);
              } else {
                selectedTriggers.remove(trigger);
              }
            });
          },
          selectedColor: Colors.teal,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Mood & Stress Tracking'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'How do you feel today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSelectableChips(
              options: moodOptions,
              selectedValue: selectedMood,
              onSelected: (val) => setState(() => selectedMood = val),
            ),
            const SizedBox(height: 30),
            const Text(
              'What triggered your mood today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildMultiSelectChips(),
            const SizedBox(height: 30),
            const Text(
              'Top Emotion Today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSelectableChips(
              options: emotionOptions,
              selectedValue: topEmotion,
              onSelected: (val) => setState(() => topEmotion = val),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // TODO: Save/submit logic
                debugPrint('Mood: $selectedMood');
                debugPrint('Triggers: $selectedTriggers');
                debugPrint('Emotion: $topEmotion');
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
