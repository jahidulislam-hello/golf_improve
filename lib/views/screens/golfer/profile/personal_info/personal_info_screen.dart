import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/profile/personal_info/personal_info_controller.dart';


class GolferPersonalInfoScreen extends StatefulWidget {
  const GolferPersonalInfoScreen({
    super.key,
    required this.name,
    required this.handicap,
    this.onSaved,
  });

  /// Current name / handicap, usually passed in from ProfileController.
  final String name;
  final double handicap;

  /// Called after Save Changes succeeds so the caller (Profile screen)
  /// can update its own state.
  final void Function(String name, double handicap)? onSaved;

  @override
  State<GolferPersonalInfoScreen> createState() => _GolferPersonalInfoScreenState();
}

class _GolferPersonalInfoScreenState extends State<GolferPersonalInfoScreen> {
  late final GolferPersonalInfoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GolferPersonalInfoController(
      name: widget.name,
      handicapIndex: widget.handicap,
    );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    await _controller.saveChanges();
    widget.onSaved?.call(
      _controller.nameController.text,
      _controller.handicapIndex,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SizedBox(height: 8),
          Center(child: _AvatarPicker()),
          const SizedBox(height: 28),
          _FieldLabel('Full Name'),
          const SizedBox(height: 8),
          _TextInputBox(
            controller: _controller.nameController,
            hintText: 'Alex Thompson',
          ),
          const SizedBox(height: 20),
          _FieldLabel('Email'),
          const SizedBox(height: 8),
          _TextInputBox(
            controller: _controller.emailController,
            hintText: 'example@gmail.com',
            enabled: false,
          ),
          const SizedBox(height: 20),
          _FieldLabel('Age Range'),
          const SizedBox(height: 8),
          _AgeRangeDropdown(controller: _controller),
          const SizedBox(height: 20),
          _FieldLabel('Gender'),
          const SizedBox(height: 8),
          _GenderPicker(controller: _controller),
          const SizedBox(height: 20),
          _HandicapCard(controller: _controller),
          const SizedBox(height: 20),
          _FieldLabel('Practice Sessions Per Week'),
          const SizedBox(height: 8),
          _PracticeSessionsPicker(controller: _controller),
          const SizedBox(height: 28),
          _SaveChangesButton(onPressed: _handleSave),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundOffWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text('Personal Info', style: AppTextStyles.appBarTitle),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTextStyles.fieldLabel);
  }
}

class _AvatarPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_outlined, size: 28, color: AppColors.ctaBrightBlue),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.ctaBrightBlue,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.backgroundOffWhite, width: 2),
              ),
              child: const Icon(Icons.add, size: 16, color: AppColors.surfaceWhite),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInputBox extends StatelessWidget {
  const _TextInputBox({
    required this.controller,
    required this.hintText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColors.surfaceWhite : AppColors.borderLightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: AppTextStyles.inputValue,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintText: hintText,
          hintStyle: AppTextStyles.inputValue.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _AgeRangeDropdown extends StatelessWidget {
  const _AgeRangeDropdown({required this.controller});
  final GolferPersonalInfoController controller;

  static const List<String> _options = [
    'Under 18',
    '18–24',
    '25–34',
    '35–44',
    '45–54',
    '55–64',
    '65+',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.ageRange,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          hint: const Text('Select Your Age', style: AppTextStyles.inputValue),
          style: AppTextStyles.inputValue,
          items: _options
              .map((age) => DropdownMenuItem(value: age, child: Text(age)))
              .toList(),
          onChanged: controller.setAgeRange,
        ),
      ),
    );
  }
}

class _GenderPicker extends StatelessWidget {
  const _GenderPicker({required this.controller});
  final GolferPersonalInfoController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Gender.values.map((g) {
        final selected = controller.gender == g;
        return _SegmentPill(
          label: g.label,
          selected: selected,
          onTap: () => controller.setGender(g),
        );
      }).toList(),
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryNavy : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: selected ? AppTextStyles.segmentLabelActive : AppTextStyles.segmentLabel,
        ),
      ),
    );
  }
}

class _HandicapCard extends StatelessWidget {
  const _HandicapCard({required this.controller});
  final GolferPersonalInfoController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _FieldLabel('Handicap Index'),
            Text(
              'Range: ${GolferPersonalInfoController.minHandicap} to ${GolferPersonalInfoController.maxHandicap}',
              style: AppTextStyles.type11,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StepperButton(icon: Icons.remove, onTap: controller.decrementHandicap),
                  Text(
                    controller.handicapIndex.toStringAsFixed(1),
                    style: AppTextStyles.statNumber.copyWith(fontSize: 28),
                  ),
                  _StepperButton(icon: Icons.add, onTap: controller.incrementHandicap),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: controller.handicapProgress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppColors.borderLightGray,
                  valueColor: const AlwaysStoppedAnimation(AppColors.ctaBrightBlue),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('PRO LEVEL', style: AppTextStyles.type10),
                  Text('BEGINNER', style: AppTextStyles.type10),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: AppColors.primaryNavy, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: AppColors.surfaceWhite),
      ),
    );
  }
}

class _PracticeSessionsPicker extends StatelessWidget {
  const _PracticeSessionsPicker({required this.controller});
  final GolferPersonalInfoController controller;

  @override
  Widget build(BuildContext context) {
    final options = {'1': 1, '2': 2, '3+': 3};
    return Row(
      children: options.entries.map((entry) {
        final selected = controller.practiceSessionsPerWeek == entry.value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => controller.setPracticeSessionsPerWeek(entry.value),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryNavy : AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  entry.key,
                  style: selected ? AppTextStyles.segmentLabelActive : AppTextStyles.segmentLabel,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SaveChangesButton extends StatelessWidget {
  const _SaveChangesButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ctaBrightBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Save Changes', style: AppTextStyles.buttonLabel),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 18, color: AppColors.surfaceWhite),
          ],
        ),
      ),
    );
  }
}
