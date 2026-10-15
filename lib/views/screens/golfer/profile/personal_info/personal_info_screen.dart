import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/profile/personal_info/personal_info_controller.dart';
import 'package:golf_training_app/core/app_radii.dart';


class GolferPersonalInfoScreen extends StatefulWidget {
  const GolferPersonalInfoScreen({
    super.key,
    this.onSaved,
  });

  /// Called after Save Changes succeeds so the caller (Profile screen)
  /// can update its own state.
  final void Function(PersonalInfoPayload payload)? onSaved;

  @override
  State<GolferPersonalInfoScreen> createState() => _GolferPersonalInfoScreenState();
}

class _GolferPersonalInfoScreenState extends State<GolferPersonalInfoScreen> {
  late final GolferPersonalInfoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GolferPersonalInfoController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    await _controller.pickAvatarFromGallery();
    if (!mounted) return;
    final message = _controller.errorMessage;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleSave() async {
    final success = await _controller.saveChanges();
    if (!success) {
      if (!mounted) return;
      final message = _controller.errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }
    if (_controller.emailChangePending) {
      final verified = await _promptEmailCode();
      if (!verified || !mounted) return;
    }
    widget.onSaved?.call(
      PersonalInfoPayload(
        name: _controller.nameController.text.trim(),
        email: _controller.emailController.text.trim(),
        ageRange: _controller.ageRange,
        genderLabel: _controller.gender?.label ?? '',
        practiceSessionsPerWeek: _controller.practiceSessionsPerWeek,
        handicap: _controller.handicapIndex,
        avatarUrl: _controller.avatarUrl,
      ),
    );
    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.pop();
    ScaffoldMessenger.of(navigator.context).showSnackBar(
      const SnackBar(content: Text('Profile saved.')),
    );
  }

  Future<bool> _promptEmailCode() async {
    final codeController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Verify new email'),
          content: TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '6-digit code',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return false;
    final ok = await _controller.confirmEmailChange(codeController.text);
    codeController.dispose();
    if (!ok && mounted) {
      final message = _controller.errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: _buildAppBar(context),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: _AvatarPicker(
              imageUrl: _controller.avatarUrl,
              localPath: _controller.localAvatarPath,
              isBusy: _controller.isPickingAvatar,
              onTap: _controller.isPickingAvatar ? null : _pickAvatar,
            ),
          ),
          const SizedBox(height: 28),
          _FieldCard(
            label: 'Full Name',
            child: _TextInputBox(
              controller: _controller.nameController,
              hintText: 'Full name',
            ),
          ),
          const SizedBox(height: 16),
          _FieldCard(
            label: 'Email',
            child: _TextInputBox(
              controller: _controller.emailController,
              hintText: 'Email',
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),
          _FieldCard(
            label: 'Age Range',
            child: _AgeRangeDropdown(controller: _controller),
          ),
          const SizedBox(height: 16),
          _HandicapCard(controller: _controller),
          const SizedBox(height: 16),
          _FieldCard(
            label: 'Practice Sessions Per Week',
            child: _PracticeSessionsPicker(controller: _controller),
          ),
          const SizedBox(height: 28),
          _SaveChangesButton(
            onPressed: _controller.isSaving ? null : _handleSave,
            isSaving: _controller.isSaving,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceWhite,
      surfaceTintColor: AppColors.surfaceWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.borderLightGray,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
      ),
      title: const Text(
        'Golf Profile',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class PersonalInfoPayload {
  const PersonalInfoPayload({
    required this.name,
    required this.email,
    required this.ageRange,
    required this.genderLabel,
    required this.practiceSessionsPerWeek,
    required this.handicap,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String? ageRange;
  final String genderLabel;
  final int practiceSessionsPerWeek;
  final double handicap;
  final String? avatarUrl;
}

/// White card that holds a field label + its control together,
/// matching the "Full Name" / "Email" / "Age Range" / "Gender" /
/// "Practice Sessions Per Week" cards in the design.
class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label),
          const SizedBox(height: 12),
          child,
        ],
      ),
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
  const _AvatarPicker({
    this.imageUrl,
    this.localPath,
    this.isBusy = false,
    this.onTap,
  });

  final String? imageUrl;
  final String? localPath;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasLocal = localPath != null && localPath!.isNotEmpty;
    final hasNetwork = imageUrl != null && imageUrl!.isNotEmpty;
    final ImageProvider? image = hasLocal
        ? FileImage(File(localPath!))
        : (hasNetwork ? NetworkImage(imageUrl!) : null);

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.backButtonBorder,
                  shape: BoxShape.circle,
                  image: image == null
                      ? null
                      : DecorationImage(image: image, fit: BoxFit.cover),
                ),
                child: image == null
                    ? const Icon(
                        Icons.camera_alt_outlined,
                        size: 28,
                        color: AppColors.ctaBrightBlue,
                      )
                    : null,
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.ctaBrightBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundOffWhite,
                      width: 2,
                    ),
                  ),
                  child: isBusy
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surfaceWhite,
                          ),
                        )
                      : const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.surfaceWhite,
                        ),
                ),
              ),
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
        borderRadius: BorderRadius.circular(28), // fully pill-shaped, per design
        border: enabled ? Border.all(color: AppColors.borderLightGray, width: AppRadii.cardBorderWidth) : null,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundOffWhite,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLightGray, width: AppRadii.cardBorderWidth),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.ageRange,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          hint: const Text('Select Your Age', style: AppTextStyles.inputValue),
          style: AppTextStyles.inputValue,
          items: GolferPersonalInfoController.ageRangeOptions
              .map((age) => DropdownMenuItem(value: age, child: Text(age)))
              .toList(),
          onChanged: controller.setAgeRange,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Column(
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
          const SizedBox(height: 12),
          // Inner white card — holds only the stepper row + underline.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.backgroundOffWhite,
              borderRadius: BorderRadius.circular(16),
              border: AppRadii.cardBorder,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StepperButton(icon: Icons.remove, onTap: controller.decrementHandicap),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: controller.handicapController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d{0,2}\.?\d{0,1}$'),
                          ),
                        ],
                        style: AppTextStyles.statNumber.copyWith(fontSize: 28),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    _StepperButton(icon: Icons.add, onTap: controller.incrementHandicap),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.ctaBrightBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
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
                  color: selected ? AppColors.primaryNavy : AppColors.pillInactive,
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
  const _SaveChangesButton({required this.onPressed, required this.isSaving});
  final VoidCallback? onPressed;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ctaBrightBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonBorderRadius),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSaving) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.surfaceWhite,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Text('Save Profile', style: AppTextStyles.buttonLabel),
            const SizedBox(width: 8),
            // const Icon(Icons.arrow_forward, size: 18, color: AppColors.surfaceWhite),
          ],
        ),
      ),
    );
  }
}