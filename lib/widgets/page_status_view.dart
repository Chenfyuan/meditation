import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

class PageStatusView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isDark;
  final bool isLoading;

  const PageStatusView.loading({
    super.key,
    this.message = '内容加载中…',
    this.isDark = false,
  }) : onRetry = null,
       isLoading = true;

  const PageStatusView.error({
    super.key,
    required this.message,
    required this.onRetry,
    this.isDark = false,
  }) : isLoading = false;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.white.withAlpha(166)
        : AppColors.textSecondary;
    final accentColor = isDark ? AppColors.sleepAccent : AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: accentColor,
                ),
              ),
            if (isLoading) const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.sans(
                fontSize: 15,
                color: isLoading ? secondaryColor : textColor,
              ),
            ),
            if (!isLoading && onRetry != null) const SizedBox(height: 18),
            if (!isLoading && onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  '重试',
                  style: AppFonts.sans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
