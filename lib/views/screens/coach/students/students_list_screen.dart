import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'student.dart';
import 'student_detail_screen.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  static final List<Student> students = [
    Student(name: 'Alex Thompson', handicap: 12.4, swingsThisWeek: 12, avgScore: 84,
        progressColor: AppColors.ctaBrightBlue, totalSwings: 847, sessions: 47,
        recentUploads: [
          {'title': 'Driver · Face On', 'time': 'Today, 9:14 AM', 'score': 84},
          {'title': '7 Iron · Down the Line', 'time': 'Yesterday', 'score': 91},
          {'title': 'Wedge · Side On', 'time': 'Mon, 11:00 AM', 'score': 76},
        ]),
    Student(name: 'Sarah Chen', handicap: 8.1, swingsThisWeek: 8, avgScore: 91,
        progressColor: AppColors.successGreen, totalSwings: 612, sessions: 35),
    Student(name: 'Mike Rodriguez', handicap: 18.5, swingsThisWeek: 6, avgScore: 72,
        progressColor: AppColors.quickActionShareIcon, totalSwings: 401, sessions: 22),
    Student(name: 'Emma Park', handicap: 15.0, swingsThisWeek: 15, avgScore: 88,
        progressColor: AppColors.successGreen, totalSwings: 733, sessions: 41),
  ];

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
              Text('${students.length} students', style: AppTextStyles.caption),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final s = students[i];
                    return _StudentCard(
                      student: s,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => StudentDetailScreen(student: s)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap, // <-- THIS is what pushes to the second screen
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderCard),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
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
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      'HCP ${student.handicap.toStringAsFixed(1)} · ${student.swingsThisWeek} swings this week',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: student.avgScore / 100,
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
                  Text('${student.avgScore}%',
                      style: AppTextStyles.type20.copyWith(
                          fontWeight: FontWeight.w800, color: AppColors.primaryNavy)),
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