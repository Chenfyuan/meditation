import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import '../theme/app_colors.dart';

class WeeklyChart extends StatelessWidget {
  final List<int> data;
  final int highlightIndex;

  const WeeklyChart({
    super.key,
    required this.data,
    this.highlightIndex = 5,
  });

  static const _labels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final isHighlight = i == highlightIndex;
        final height = maxVal > 0 ? (data[i] / maxVal) * 84 : 0.0;
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: height.clamp(8.0, 84.0),
                decoration: BoxDecoration(
                  color: isHighlight
                      ? AppColors.primary
                      : const Color(0xFFE2D3C2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _labels[i],
                style: AppFonts.sans(
                  fontSize: 12,
                  color: isHighlight ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
