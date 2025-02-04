import 'package:flutter/material.dart';

enum Gender { male, female }

class GenderSelector extends StatefulWidget {
  final void Function(Gender)? onGenderSelected;
  final Gender? initialGender;

  const GenderSelector({
    Key? key,
    this.onGenderSelected,
    this.initialGender,
  }) : super(key: key);

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  Gender? selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.purple[900],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedGender = Gender.male;
                  });
                  widget.onGenderSelected?.call(Gender.male);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedGender == Gender.male
                        ? Colors.purple[100]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Male',
                      style: TextStyle(
                        color: selectedGender == Gender.male
                            ? Colors.purple[900]
                            : Colors.purple[300],
                        fontWeight: selectedGender == Gender.male
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedGender = Gender.female;
                  });
                  widget.onGenderSelected?.call(Gender.female);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedGender == Gender.female
                        ? Colors.purple[100]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Female',
                      style: TextStyle(
                        color: selectedGender == Gender.female
                            ? Colors.purple[900]
                            : Colors.purple[300],
                        fontWeight: selectedGender == Gender.female
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
