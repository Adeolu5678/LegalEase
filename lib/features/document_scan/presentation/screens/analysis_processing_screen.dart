import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/document_scan/presentation/providers/document_scan_providers.dart';

class AnalysisProcessingScreen extends ConsumerStatefulWidget {
  const AnalysisProcessingScreen({super.key});

  @override
  ConsumerState<AnalysisProcessingScreen> createState() => _AnalysisProcessingScreenState();
}

class _AnalysisProcessingScreenState extends ConsumerState<AnalysisProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _simulateAnalysis();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _simulateAnalysis() async {
    final notifier = ref.read(analysisNotifierProvider.notifier);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    notifier.updateStep(AnalysisStep.extractingText, progress: 0.1);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    notifier.updateStep(AnalysisStep.extractingText, progress: 0.25);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    notifier.updateStep(AnalysisStep.analyzing, progress: 0.35);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    notifier.updateStep(AnalysisStep.analyzing, progress: 0.55);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    notifier.updateStep(AnalysisStep.detectingRedFlags, progress: 0.65);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    notifier.updateStep(AnalysisStep.detectingRedFlags, progress: 0.80);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    notifier.updateStep(AnalysisStep.generatingSummary, progress: 0.85);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    notifier.updateStep(AnalysisStep.generatingSummary, progress: 0.95);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    notifier.updateStep(AnalysisStep.completed, progress: 1.0);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.replace('/analysis/result');
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    ref.read(analysisNotifierProvider.notifier).cancelAnalysis();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleCancel();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildAnimatedHeader(context),
                const Spacer(),
                _buildCentralAnimation(context),
                const SizedBox(height: 48),
                _buildProgressIndicator(context, analysisState),
                const SizedBox(height: 24),
                _buildProgressBar(context, analysisState),
                const Spacer(),
                _buildCancelButton(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          'Analyzing Document',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
        const SizedBox(height: 8),
        Text(
          'Please wait while our AI processes your document',
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
      ],
    );
  }

  Widget _buildCentralAnimation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 180 + (_pulseController.value * 20),
              height: 180 + (_pulseController.value * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.primaryContainer.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _ProgressRingPainter(
                    color: colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 48,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.5, 0.5));
  }

  Widget _buildProgressIndicator(BuildContext context, AnalysisState state) {
    final steps = [
      (AnalysisStep.extractingText, 'Extracting Text', Icons.text_fields_rounded),
      (AnalysisStep.analyzing, 'Analyzing', Icons.analytics_rounded),
      (AnalysisStep.detectingRedFlags, 'Detecting Red Flags', Icons.warning_amber_rounded),
      (AnalysisStep.generatingSummary, 'Generating Summary', Icons.summarize_rounded),
    ];

    final currentStepIndex = steps.indexWhere((s) => s.$1 == state.currentStep);
    final activeIndex = currentStepIndex == -1 ? 0 : currentStepIndex;

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final (step, label, icon) = entry.value;
        final isActive = index <= activeIndex;
        final isCurrent = step == state.currentStep;

        return _StepItem(
          icon: icon,
          label: label,
          isActive: isActive,
          isCurrent: isCurrent,
          isLast: index == steps.length - 1,
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
      }).toList(),
    );
  }

  Widget _buildProgressBar(BuildContext context, AnalysisState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              '${(state.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: state.progress),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _handleCancel,
      icon: const Icon(Icons.close_rounded),
      label: const Text('Cancel Analysis'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCurrent;
  final bool isLast;

  const _StepItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? (isCurrent ? colorScheme.primary : colorScheme.primaryContainer)
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: colorScheme.primary, width: 2)
                      : null,
                ),
                child: Icon(
                  isActive && !isCurrent ? Icons.check_rounded : icon,
                  size: 18,
                  color: isActive
                      ? (isCurrent ? colorScheme.onPrimary : colorScheme.onPrimaryContainer)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 2,
                    color: isActive
                        ? colorScheme.primary.withValues(alpha: 0.5)
                        : colorScheme.surfaceContainerHighest,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isActive
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                  if (isCurrent)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const sweepAngle = 1.5;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawArc(
      rect,
      0,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
