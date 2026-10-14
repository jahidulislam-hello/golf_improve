
import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';




class TermsCondition extends StatelessWidget {
  const TermsCondition({super.key});
  static final _textDark = AppColors.textPrimary;
  static final _textMid = AppColors.textSecondary;
  static const _bg = AppColors.backgroundOffWhite;

  // FIX: border color for the policy points box
  static const _boxBorderColor = Color(0xFFF4C9DF);

  static const _policyPoints = [
    'Lorem ipsum dolor sit amet consectetur. Lacus at venenatis gravida vivamus mauris. Quisque mi est vel dis. Donec rhoncus laoreet odio orci sed risus elit accumsan. Mattis ut est tristique amet vitae at aliquet. Ac vel porttitor egestas scelerisque enim quisque senectus. Euismod ultricies vulputate id cras bibendum sollicitudin proin odio bibendum. Velit velit in scelerisque erat etiam rutrum phasellus nunc. Sed lectus sed a at et eget. Nunc purus sed quis at risus. Consectetur nibh justo proin placerat condimentum id at adipiscing.',
    'Vel blandit mi nulla sodales consectetur. Egestas tristique ultrices gravida duis nisl odio. Posuere curabitur eu platea pellentesque ut. Facilisi elementum neque mauris facilisis in. Cursus condimentum ipsum pretium consequat turpis at porttitor nisi.',
    'Scelerisque tellus praesent condimentum euismod a faucibus. Auctor at ultricies at urna aliquam massa pellentesque. Vitae vulputate nullam diam placerat at magna egestas. Lectus lectus consequat porta lectus purus. Nulla duis sem sit at imperdiet lobortis dui. Nunc tellus cursus maecenas phasellus sollicitudin donec dictum. Sodales in faucibus libero augue vestibulum urna mattis curabitur. Sed nullam consectetur euismod a laoreet dui. Nulla porttitor urna id blandit.',
    'Pretium pulvinar morbi suspendisse mattis.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/terms.png",
                  width: 328,
                  height: 172,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // ── Title ──
            Text(
              'Terms & Conditions',
              style: TextStyle(
                color: _textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 16),

            // FIX: bullet points now wrapped in a bordered box.
            // Background stays _bg (same as page background) per request
            // ("background background" = keep existing bg, just add the
            // border) — only the border color is new: #F4C9DF.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _boxBorderColor, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _policyPoints
                    .map((point) => _bulletItem(point))
                    .toList(),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──
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
        'Terms & Conditions',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── Bullet Item ──
  // FIX: last item in the list no longer carries a bottom margin (avoids
  // extra empty space at the bottom of the box).
  Widget _bulletItem(String text) {
    final bool isLast = text == _policyPoints.last;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: _textMid,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _textMid,
                fontSize: 13,
                height: 1.65,
                letterSpacing: 0.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}