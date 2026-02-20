import '../../../../core/exports.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: AppColors.white54,
              size: AppConstants.icon80,
            ),
            const SizedBox(height: AppConstants.spacing24),
            Text(
              Strings.noInternetTitle,
              style: TextStyle(
                color: AppColors.white,
                fontSize: AppConstants.font20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Text(
              Strings.noInternetMessage,
              style: TextStyle(
                color: AppColors.white70,
                fontSize: AppConstants.font14,
              ),
            ),
            const SizedBox(height: AppConstants.spacing32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(Strings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.buttonHorizontalPadding,
                  vertical: AppConstants.buttonVerticalPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radius30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
