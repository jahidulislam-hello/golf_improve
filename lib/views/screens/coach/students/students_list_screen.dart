import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'student.dart';
import 'student_detail_screen.dart';
import 'students_controller.dart';
import 'package:golf_training_app/core/app_radii.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, this.controller});

  final StudentsController? controller;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  late final StudentsController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? StudentsController();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Students', style: AppTextStyles.screenTitle),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.pillInactive,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.add, color: AppColors.primaryNavy, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_controller.totalStudents} students',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_controller.isLoading && !_controller.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.errorMessage != null && !_controller.hasLoaded) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _controller.errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: () => _controller.loadStudents(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.ctaBrightBlue,
      onRefresh: _controller.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _controller.students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = _controller.students[i];
          return _StudentCard(
            student: s,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => StudentDetailScreen(student: s)),
            ),
          );
        },
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  const _StudentCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      borderRadius: AppRadii.cardBorderRadius,
      child: InkWell(
        borderRadius: AppRadii.cardBorderRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.cardBorderRadius,
            border: AppRadii.cardBorder,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
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
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'HCP ${student.handicap.toStringAsFixed(1)} · ${student.swingsThisWeek} swings this week',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (student.avgScore / 100).clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: AppColors.pillInactive,
                        valueColor: AlwaysStoppedAnimation(student.progressColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${student.avgScore}%',
                    style: AppTextStyles.type20.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('Avg score', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
