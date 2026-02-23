import '../../../../core/exports.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: AppColors.red,
          size: AppConstants.errorIconSize,
        ),
        const SizedBox(height: AppConstants.spacing16),
        Text(
          message,
          style: const TextStyle(color: AppColors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing16),
        ElevatedButton(onPressed: onRetry, child: const Text(Strings.retry)),
      ],
    ),
  );
}
