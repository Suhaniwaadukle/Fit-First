import 'package:flutter/material.dart';

class HairCareScreen extends StatefulWidget {
  const HairCareScreen({super.key});

  @override
  State<HairCareScreen> createState() => _HairCareScreenState();
}

class _HairCareScreenState extends State<HairCareScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Coming Soon..",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
