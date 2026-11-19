import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/common_content_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CmsDocumentType { about, terms, privacy }

/// Loads About / Terms / Privacy from `/common/*` CMS endpoints.
class CmsDocumentScreen extends StatefulWidget {
  const CmsDocumentScreen({
    super.key,
    required this.type,
    required this.fallbackTitle,
    this.assetImage,
  });

  final CmsDocumentType type;
  final String fallbackTitle;
  final String? assetImage;

  @override
  State<CmsDocumentScreen> createState() => _CmsDocumentScreenState();
}

class _CmsDocumentScreenState extends State<CmsDocumentScreen> {
  static const _boxBorderColor = Color(0xFFF4C9DF);

  bool _loading = true;
  String? _error;
  String _title = '';
  List<String> _paragraphs = const [];

  @override
  void initState() {
    super.initState();
    _title = widget.fallbackTitle;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final service = CommonContentService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final Map<String, dynamic> response;
      switch (widget.type) {
        case CmsDocumentType.about:
          response = await service.getAbout();
          break;
        case CmsDocumentType.terms:
          response = await service.getTerms();
          break;
        case CmsDocumentType.privacy:
          response = await service.getPrivacyPolicy();
          break;
      }
      final paragraphs = CommonContentService.paragraphsFrom(response);
      final title =
          CommonContentService.titleFrom(response) ?? widget.fallbackTitle;
      if (!mounted) return;
      setState(() {
        _title = title;
        _paragraphs = paragraphs.isEmpty
            ? _fallbackParagraphs(widget.type)
            : paragraphs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _paragraphs = _fallbackParagraphs(widget.type);
        _error = null;
        _loading = false;
      });
    }
  }

  static List<String> _fallbackParagraphs(CmsDocumentType type) {
    switch (type) {
      case CmsDocumentType.about:
        return const [
          'GolfImprove helps golfers record swings, get AI coaching insights, track progress, and share clips privately with a coach.',
          'Coaches review student swings, leave feedback, and assign practice plans from one place.',
        ];
      case CmsDocumentType.terms:
        return const [
          'By using GolfImprove you agree to use the app for personal golf training and coaching, and not to misuse uploaded media or account access.',
          'AI suggestions are experimental and do not replace professional coaching or medical advice.',
          'Subscriptions, trials, and promo redemptions are subject to the plan terms shown at purchase or redemption time.',
        ];
      case CmsDocumentType.privacy:
        return const [
          'We collect account details, swing videos, practice notes, and device tokens needed to provide GolfImprove.',
          'You can export or delete your account from Profile → Privacy & Legal.',
          'Videos shared with a coach are private to that coaching relationship.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: AppColors.surfaceWhite,
        elevation: 0,
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
        title: Text(
          widget.fallbackTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.assetImage != null) ...[
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            widget.assetImage!,
                            width: 328,
                            height: 172,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    Text(
                      _title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundOffWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _boxBorderColor, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < _paragraphs.length; i++) ...[
                            _bullet(_paragraphs[i]),
                            if (i != _paragraphs.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _bullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: SizedBox(
            width: 5,
            height: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.65,
              letterSpacing: 0.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
