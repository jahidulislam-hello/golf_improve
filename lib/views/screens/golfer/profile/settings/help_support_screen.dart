
import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';


class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // ← centers all children
        children: [
          const Spacer(),

          // ── Illustration ──────────────────────────────────
          Center(
            child: Image.asset(
              'assets/images/support.png',
              width: 230,
              height: 280,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 28),

          // ── Description ───────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'If you face any kind of problem with our service feel free to contact us.',
              textAlign: TextAlign.center, // ← centers text within its box
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Email contact pill ────────────────────────────
          Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4C9DF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border:
                Border.all(color: const Color(0xFFC23F82), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // ← shrinks to content width
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.ctaBrightBlue,
                      shape: BoxShape.circle,
                    ),
                    child:  Icon(
                      Icons.mail_outline_rounded,
                      color: AppColors.cardBackground,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'example12345@gmail.com',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
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
        'Help & Support',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}