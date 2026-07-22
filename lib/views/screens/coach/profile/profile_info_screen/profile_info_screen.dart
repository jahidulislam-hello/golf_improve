import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/coach/profile/profile_screen/profile_controller.dart';


class PersonalInfoScreen extends StatefulWidget {
  final ProfileController controller;
  const PersonalInfoScreen({super.key, required this.controller});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- App bar ----
              Row(
                children: [
                  Material(
                    color: AppColors.pillInactive,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.primaryNavy),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Personal Info', style: AppTextStyles.appBarTitle),
                ],
              ),
              const SizedBox(height: 28),

              // ---- Avatar picker ----
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.noteHighlightBg, // soft pink bg
                        shape: BoxShape.circle,
                      ),
                      child: c.profileImagePath != null
                          ? ClipOval(
                        child: Image.network(c.profileImagePath!, fit: BoxFit.cover),
                      )
                          : Icon(Icons.camera_alt_outlined, color: AppColors.ctaBrightBlue, size: 28),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: AppColors.ctaBrightBlue,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            // TODO: hook up image_picker here, then:
                            // c.setProfileImage(pickedPath);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ---- Full name ----
              Text('Full Name', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLightGray),
                ),
                child: TextField(
                  controller: c.fullNameController,
                  style: AppTextStyles.inputValue,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    hintText: 'Full name',
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ---- Email ----
              Text('Email', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pillInactive,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: c.emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.inputValue,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    hintText: 'example@gmail.com',
                  ),
                ),
              ),

              const Spacer(),

              // ---- Save button ----
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: AppColors.ctaBrightBlue,
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: c.isSaving
                        ? null
                        : () async {
                      final success = await c.saveChanges();
                      if (!context.mounted) return;
                      if (success) {
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please check your name and email.')),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: c.isSaving
                          ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Save Changes', style: AppTextStyles.buttonLabel),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}