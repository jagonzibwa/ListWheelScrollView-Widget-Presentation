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



class AlarmPickerPage extends StatefulWidget {
  const AlarmPickerPage({super.key});

  @override
  State<AlarmPickerPage> createState() => _AlarmPickerPageState();
}

class _AlarmPickerPageState extends State<AlarmPickerPage> {
  // Labels for the AM/PM wheel, indexed the same way as _selectedPeriod.
  static const List<String> _periods = ['AM', 'PM'];


  int _selectedHour = 6; // index 6 → displayed as "07" (hours are 1-indexed)
  int _selectedMinute = 30; // index 30 → displayed as "30"
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

/// three synced ListWheelScrollViews (hour,
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

  // Height of a single row in every wheel, in logical pixels. All three
  // wheels must use the same itemExtent so their rows line up horizontally.
  static const double _itemExtent = 44;
  // How many rows are visible in the wheel's viewport at once (must be odd
  // so there's a single centered row). Used only to size the picker's box.
  static const int _visibleItemCount = 5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      // Fixes the picker's overall height so the wheels have a bounded
      // viewport to scroll within (ListWheelScrollView needs a finite
      // height from its parent, it won't size itself to its content).
      height: _itemExtent * _visibleItemCount,
      width: 280,
      child: Stack(
        // Stack layers the highlight bar behind the three wheel columns so
        // it sits right at the center row of all of them simultaneously.
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
          // The three scrollable columns, laid out side by side.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour wheel: 12 items (indexes 0-11), labeled "01".."12".
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
              // Minute wheel: 60 items (indexes 0-59), labeled "00".."59".
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
              // AM/PM wheel: just 2 items.
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

/// The ":" divider drawn between the hour and minute wheels. Its own tiny
/// widget purely to avoid repeating the same Text/style pair inline.
class _WheelSeparator extends StatelessWidget {
  const _WheelSeparator({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 24));
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.itemCount,
    required this.selectedItem,
    required this.itemExtent,
    required this.labelBuilder,
    required this.onChanged,
  });

  // How many rows this wheel has in total 
  final int itemCount;
  // Index of the row that should start out centered/selected.
  final int selectedItem;
  // Fixed pixel height of every row required by ListWheelScrollView so it
  // can work out scroll offsets without measuring each child.
  final double itemExtent;
  // Turns a row's index into the text it displays 
  final String Function(int index) labelBuilder;
  // Called with the new index whenever the user scrolls to a different row.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      // Every row is exactly this tall
      itemExtent: itemExtent,
      // diameterRatio controls how "curved" the wheel looks 
      diameterRatio: 1.5,
      // perspective adds the 3D vanishing-point effect so rows further from
      // the center look like they're rotating away from the viewer, Valid range is 0 (flat) to 0.01.
      perspective: 0.005,
      // FixedExtentScrollPhysics makes the wheel always settle with one
      // item exactly centered
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
