import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'student.dart';
import 'package:golf_training_app/core/app_radii.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primaryNavy),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.quickActionAiBg,
                    child: Text(student.initials,
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.quickActionAiIcon, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.name,
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
                        const SizedBox(height: 2),
                        Text('Handicap ${student.handicap.toStringAsFixed(1)} · Active',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _StatCard(value: '${student.totalSwings}', label: 'Swings')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: '${student.avgScore}%', label: 'Avg Score')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: '${student.sessions}', label: 'Sessions')),
                ],
              ),
              const SizedBox(height: 24),
              Text('Recent Uploads', style: AppTextStyles.sectionHeader),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: AppRadii.cardBorderRadius,
                        border: AppRadii.cardBorder,
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < student.recentUploads.length; i++) ...[
                            _UploadRow(
                              title: student.recentUploads[i]['title'],
                              time: student.recentUploads[i]['time'],
                              score: student.recentUploads[i]['score'],
                            ),
                            if (i != student.recentUploads.length - 1)
                              const Divider(
                                height: 1.11,
                                thickness: 1.11,
                                color: Color(0xFFF1F5F9),
                                indent: 16,
                                endIndent: 16,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: AppRadii.cardBorder,
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.statNumber.copyWith(fontSize: 24, height: 1)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _UploadRow extends StatelessWidget {
  final String title;
  final String time;
  final int score;
  const _UploadRow({required this.title, required this.time, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.quickActionLogbookBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.golf_course, color: AppColors.quickActionLogbookIcon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(time, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            '$score%',
            style: AppTextStyles.type16.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}
