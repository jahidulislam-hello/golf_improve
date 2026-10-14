import 'package:flutter/material.dart';
import 'package:golf_training_app/core/app_colors.dart';
import 'package:golf_training_app/core/app_radii.dart';
import 'package:golf_training_app/core/app_styles.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/clip_header_row.dart';
import 'package:golf_training_app/views/screens/golfer/home/compare_swings/compare_result.dart';
import 'package:golf_training_app/views/screens/golfer/library/widgets/video_preview.dart';

import 'compare_swings_controller.dart';


class CompareSwingsScreen extends StatefulWidget {
  const CompareSwingsScreen({
    super.key,
    this.initialSwingAId,
    this.initialSwingBId,
  });

  final String? initialSwingAId;
  final String? initialSwingBId;

  @override
  State<CompareSwingsScreen> createState() => _CompareSwingsScreenState();
}

class _CompareSwingsScreenState extends State<CompareSwingsScreen> {
  late final CompareSwingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CompareSwingsController(
      initialSwingAId: widget.initialSwingAId,
      initialSwingBId: widget.initialSwingBId,
    );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  String? _thumb(SwingClip clip) {
    final image = clip.thumbnailImage;
    if (image is NetworkImage) return image.url;
    return null;
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            _AppBarRow(
              isRefreshing: _controller.isRefreshing,
              onRefresh: _controller.refresh,
            ),
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SwingPicker(
                            label: 'Swing A',
                            value: _controller.swingAId,
                            options: _controller.optionsForPicker(
                              value: _controller.swingAId,
                              otherId: _controller.swingBId,
                            ),
                            onChanged: _controller.selectSwingA,
                          ),
                          const SizedBox(height: 12),
                          _SwingPicker(
                            label: 'Swing B',
                            value: _controller.swingBId,
                            options: _controller.optionsForPicker(
                              value: _controller.swingBId,
                              otherId: _controller.swingAId,
                            ),
                            onChanged: _controller.selectSwingB,
                          ),
                          if (_controller.options.length < 2) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Record at least two different swings to compare them.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (_controller.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _controller.errorMessage!,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.destructiveRed,
                              ),
                            ),
                          ],
                          if (_controller.isComparing) ...[
                            const SizedBox(height: 16),
                            const Center(child: CircularProgressIndicator()),
                          ],
                          const SizedBox(height: 20),
                          ClipHeaderRow(
                            clip: _controller.clipA,
                            onSpeedChanged: (speed) =>
                                _controller.setSpeed(_controller.clipA, speed),
                          ),
                          const SizedBox(height: 12),
                          VideoPreview(
                            videoUrl: _controller.clipA.videoUrl,
                            thumbnailUrl: _thumb(_controller.clipA),
                            showOverlayButtons: false,
                            borderRadius: AppRadii.cardBorderRadius,
                            playbackSpeed: _controller.clipA.speed.multiplier,
                            playRequest: _controller.playRequest,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: AppColors.borderLightGray),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: _controller.playBoth,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryNavy,
                                        foregroundColor: AppColors.surfaceWhite,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 22,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppRadii.buttonBorderRadius,
                                        ),
                                      ),
                                      child: Text(
                                        'Play Both',
                                        style: AppTextStyles.buttonLabel
                                            .copyWith(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: AppColors.borderLightGray),
                                ),
                              ],
                            ),
                          ),
                          ClipHeaderRow(
                            clip: _controller.clipB,
                            onSpeedChanged: (speed) =>
                                _controller.setSpeed(_controller.clipB, speed),
                          ),
                          const SizedBox(height: 12),
                          VideoPreview(
                            videoUrl: _controller.clipB.videoUrl,
                            thumbnailUrl: _thumb(_controller.clipB),
                            showOverlayButtons: false,
                            borderRadius: AppRadii.cardBorderRadius,
                            playbackSpeed: _controller.clipB.speed.multiplier,
                            playRequest: _controller.playRequest,
                          ),
                          if (_controller.result != null) ...[
                            const SizedBox(height: 20),
                            _ComparisonPanel(result: _controller.result!),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.isRefreshing, required this.onRefresh});

  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.pillInactive,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Compare Swings', style: AppTextStyles.appBarTitle),
          const Spacer(),
          InkWell(
            onTap: isRefreshing ? null : onRefresh,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.pillInactive,
                shape: BoxShape.circle,
              ),
              child: isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.textSecondary),
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwingPicker extends StatelessWidget {
  const _SwingPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<CompareSwingOption> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ids = options.map((option) => option.id).toSet();
    final selected = value != null && ids.contains(value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundOffWhite,
            borderRadius: BorderRadius.circular(16),
            border: AppRadii.cardBorder,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              hint: Text(
                'Choose a swing',
                style: AppTextStyles.inputValue.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              items: options
                  .map(
                    (option) => DropdownMenuItem(
                      value: option.id,
                      child: Text(
                        option.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: options.isEmpty ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonPanel extends StatelessWidget {
  const _ComparisonPanel({required this.result});

  final SwingComparisonResult result;

  @override
  Widget build(BuildContext context) {
    final score = result.score;
    final tempo = result.tempo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (score != null) _ScoreCard(score: score),
        if (tempo != null) ...[
          const SizedBox(height: 12),
          _TempoCard(tempo: tempo),
        ],
        if (result.impactOffsetMs != null) ...[
          const SizedBox(height: 12),
          Text(
            'Impact offset ${result.impactOffsetMs} ms',
            style: AppTextStyles.caption,
          ),
        ],
        for (final metric in result.metrics) ...[
          const SizedBox(height: 12),
          _MetricCard(metric: metric),
        ],
        if (result.summary.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Summary', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 8),
          Text(result.summary, style: AppTextStyles.body),
        ],
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});

  final ScoreComparison score;

  @override
  Widget build(BuildContext context) {
    final diff = score.diff;
    final sign = diff == null
        ? ''
        : diff > 0
            ? '+'
            : '';
    return _Panel(
      child: Row(
        children: [
          _ScoreValue(label: 'A', value: '${score.scoreA ?? '–'}'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Text(
                  diff == null ? '–' : '$sign$diff',
                  style: AppTextStyles.sectionHeader,
                ),
                Text(
                  score.status.replaceAll('_', ' '),
                  style: AppTextStyles.caption.copyWith(
                    color: _statusColor(score.status),
                  ),
                ),
              ],
            ),
          ),
          _ScoreValue(label: 'B', value: '${score.scoreB ?? '–'}'),
        ],
      ),
    );
  }
}

class _ScoreValue extends StatelessWidget {
  const _ScoreValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.statNumber.copyWith(fontSize: 28)),
      ],
    );
  }
}

class _TempoCard extends StatelessWidget {
  const _TempoCard({required this.tempo});

  final TempoComparison tempo;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tempo', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 8),
          Text(
            'A ${tempo.tempoA ?? '–'}  ·  B ${tempo.tempoB ?? '–'}  ·  ideal ${tempo.idealRatio ?? '–'}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 4),
          Text(
            tempo.status.replaceAll('_', ' '),
            style: AppTextStyles.caption.copyWith(color: _statusColor(tempo.status)),
          ),
          if (tempo.backswingMs != null)
            _SpanLine(title: 'Backswing', span: tempo.backswingMs!),
          if (tempo.downswingMs != null)
            _SpanLine(title: 'Downswing', span: tempo.downswingMs!),
          if (tempo.followThroughMs != null)
            _SpanLine(title: 'Follow through', span: tempo.followThroughMs!),
        ],
      ),
    );
  }
}

class _SpanLine extends StatelessWidget {
  const _SpanLine({required this.title, required this.span});

  final String title;
  final TempoSpan span;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        '$title  A ${span.swingA ?? '–'} ms · B ${span.swingB ?? '–'} ms · ${span.diffMs ?? '–'} ms',
        style: AppTextStyles.caption,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final MetricComparison metric;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metric.title, style: AppTextStyles.sectionHeader),
          if (metric.target.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(metric.target, style: AppTextStyles.caption),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _MetricSide(label: 'A', value: metric.valueA, status: metric.statusA)),
              Expanded(child: _MetricSide(label: 'B', value: metric.valueB, status: metric.statusB)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${metric.difference}  ${metric.improvement.replaceAll('_', ' ')}'.trim(),
            style: AppTextStyles.body.copyWith(
              color: _statusColor(metric.improvement),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSide extends StatelessWidget {
  const _MetricSide({
    required this.label,
    required this.value,
    required this.status,
  });

  final String label;
  final String value;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label  $value', style: AppTextStyles.body),
        Text(
          status.replaceAll('_', ' '),
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

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
      child: child,
    );
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'improved':
    case 'optimal':
    case 'straight':
      return AppColors.accentGreen;
    case 'regressed':
    case 'warning':
    case 'bent_early':
      return AppColors.destructiveRed;
    default:
      return AppColors.textSecondary;
  }
}
