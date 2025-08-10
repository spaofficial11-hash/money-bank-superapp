import 'package:flutter/material.dart';

class MLMControlScreen extends StatefulWidget {
  const MLMControlScreen({Key? key}) : super(key: key);

  @override
  State<MLMControlScreen> createState() => _MLMControlScreenState();
}

class _MLMControlScreenState extends State<MLMControlScreen> {
  double commissionLevel1 = 5.0;
  double commissionLevel2 = 3.0;
  double commissionLevel3 = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MLM Commission Control'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCommissionSlider(
              label: 'Level 1 Commission (%)',
              value: commissionLevel1,
              onChanged: (v) => setState(() => commissionLevel1 = v),
            ),
            _buildCommissionSlider(
              label: 'Level 2 Commission (%)',
              value: commissionLevel2,
              onChanged: (v) => setState(() => commissionLevel2 = v),
            ),
            _buildCommissionSlider(
              label: 'Level 3 Commission (%)',
              value: commissionLevel3,
              onChanged: (v) => setState(() => commissionLevel3 = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save commission rates to backend
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Commission rates saved')),
                );
              },
              child: const Text('Save Settings'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: 0,
          max: 20,
          divisions: 20,
          label: '${value.toStringAsFixed(1)}%',
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
