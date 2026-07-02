import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListWheelScrollView Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AlarmPickerPage(),
    );
  }
}

/// Real-world use case: a "Set Alarm" screen, the same kind of time picker
/// you see in native clock apps. Three [ListWheelScrollView]s let the user
/// spin to a value instead of typing it, which is faster and less
/// error-prone on a touch screen than a text field.
class AlarmPickerPage extends StatefulWidget {
  const AlarmPickerPage({super.key});

  @override
  State<AlarmPickerPage> createState() => _AlarmPickerPageState();
}

class _AlarmPickerPageState extends State<AlarmPickerPage> {
  static const List<String> _periods = ['AM', 'PM'];

  int _selectedHour = 6; // displayed as 7 (1-indexed)
  int _selectedMinute = 30;
  int _selectedPeriod = 0; // 0 = AM, 1 = PM

  void _confirmAlarm() {
    final hour = _selectedHour + 1;
    final minute = _selectedMinute.toString().padLeft(2, '0');
    final period = _periods[_selectedPeriod];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm set for $hour:$minute $period')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Set Alarm'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Spin the wheels to pick a time',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _TimeWheelPicker(
              selectedHour: _selectedHour,
              selectedMinute: _selectedMinute,
              selectedPeriod: _selectedPeriod,
              onHourChanged: (value) => setState(() => _selectedHour = value),
              onMinuteChanged: (value) =>
                  setState(() => _selectedMinute = value),
              onPeriodChanged: (value) =>
                  setState(() => _selectedPeriod = value),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _confirmAlarm,
              icon: const Icon(Icons.alarm_add),
              label: const Text('Save Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wheel picker itself: three synced [ListWheelScrollView]s (hour,
/// minute, AM/PM) with a shared highlight bar showing which row is selected.
class _TimeWheelPicker extends StatelessWidget {
  const _TimeWheelPicker({
    required this.selectedHour,
    required this.selectedMinute,
    required this.selectedPeriod,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onPeriodChanged,
  });

  final int selectedHour;
  final int selectedMinute;
  final int selectedPeriod;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final ValueChanged<int> onPeriodChanged;

  static const double _itemExtent = 44;
  static const int _visibleItemCount = 5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: _itemExtent * _visibleItemCount,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Highlight bar showing which row is currently selected.
          Container(
            height: _itemExtent,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _Wheel(
                  itemCount: 12,
                  selectedItem: selectedHour,
                  itemExtent: _itemExtent,
                  labelBuilder: (i) => (i + 1).toString().padLeft(2, '0'),
                  onChanged: onHourChanged,
                ),
              ),
              const _WheelSeparator(text: ':'),
              Expanded(
                child: _Wheel(
                  itemCount: 60,
                  selectedItem: selectedMinute,
                  itemExtent: _itemExtent,
                  labelBuilder: (i) => i.toString().padLeft(2, '0'),
                  onChanged: onMinuteChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Wheel(
                  itemCount: 2,
                  selectedItem: selectedPeriod,
                  itemExtent: _itemExtent,
                  labelBuilder: (i) => i == 0 ? 'AM' : 'PM',
                  onChanged: onPeriodChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WheelSeparator extends StatelessWidget {
  const _WheelSeparator({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 24));
  }
}

/// A single spinning column. This is the actual [ListWheelScrollView] usage:
/// [itemExtent] gives every row a fixed height (required by the widget),
/// [perspective] and [diameterRatio] curve the rows away from the viewer to
/// produce the 3D "wheel" look, and [onSelectedItemChanged] fires whenever
/// the centered item changes as the user flings or drags the wheel.
class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.itemCount,
    required this.selectedItem,
    required this.itemExtent,
    required this.labelBuilder,
    required this.onChanged,
  });

  final int itemCount;
  final int selectedItem;
  final double itemExtent;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      itemExtent: itemExtent,
      diameterRatio: 1.5,
      perspective: 0.005,
      physics: const FixedExtentScrollPhysics(),
      controller: FixedExtentScrollController(initialItem: selectedItem),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = index == selectedItem;
          return Center(
            child: Text(
              labelBuilder(index),
              style: TextStyle(
                fontSize: isSelected ? 22 : 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
