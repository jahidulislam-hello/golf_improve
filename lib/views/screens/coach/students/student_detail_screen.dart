import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'student.dart';
import 'student_detail_controller.dart';
import 'package:golf_training_app/core/app_radii.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late final StudentDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StudentDetailController(initial: widget.student);
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = _controller.student;
    final statusLabel = student.isActive ? 'Active' : 'Inactive';

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
                    backgroundImage: student.profileUrl.isNotEmpty
                        ? NetworkImage(student.profileUrl)
                        : null,
                    child: student.profileUrl.isEmpty
                        ? Text(
                            student.initials,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.quickActionAiIcon,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Handicap ${student.handicap.toStringAsFixed(1)} · $statusLabel',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 20),
              if (_controller.isLoading && !_controller.hasLoaded)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_controller.errorMessage != null && !_controller.hasLoaded)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _controller.loadDetails(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
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
                      if (student.recentUploads.isEmpty)
                        Text('No recent uploads', style: AppTextStyles.caption)
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: AppRadii.cardBorderRadius,
                            border: AppRadii.cardBorder,
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < student.recentUploads.length; i++) ...[
                                _UploadRow(upload: student.recentUploads[i]),
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
  final StudentUpload upload;
  const _UploadRow({required this.upload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: upload.thumbnailUrl.isEmpty
                ? Container(
                    width: 56,
                    height: 56,
                    color: AppColors.quickActionLogbookBg,
                    child: const Icon(
                      Icons.golf_course,
                      color: AppColors.quickActionLogbookIcon,
                    ),
                  )
                : Image.network(
                    upload.thumbnailUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: AppColors.quickActionLogbookBg,
                      child: const Icon(
                        Icons.golf_course,
                        color: AppColors.quickActionLogbookIcon,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upload.title,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(upload.time, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            '${upload.score}%',
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
