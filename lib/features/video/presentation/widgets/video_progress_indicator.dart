import '../../../../core/exports.dart';

class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final Color backgroundColor;
  final Color playedColor;
  final Color bufferedColor;
  final double height;

  const VideoProgressBar({
    super.key,
    required this.controller,
    this.backgroundColor = AppColors.grey900,
    this.playedColor = AppColors.white,
    this.bufferedColor = AppColors.grey,
    this.height = 3.0,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  VoidCallback? _listener;
  bool _isDragging = false;
  double _dragProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (!_isDragging && mounted) {
        setState(() {});
      }
    };
    widget.controller.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) {
      widget.controller.removeListener(_listener!);
    }
    super.dispose();
  }

  void _onTapDown(TapDownDetails details, double width) {
    final progress = details.localPosition.dx / width;
    _seekToProgress(progress);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragProgress = _getCurrentProgress();
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    if (_isDragging) {
      setState(() {
        _dragProgress = (_dragProgress + details.primaryDelta! / width).clamp(
          0.0,
          1.0,
        );
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isDragging) {
      _seekToProgress(_dragProgress);
      setState(() {
        _isDragging = false;
      });
    }
  }

  double _getCurrentProgress() {
    final duration = widget.controller.value.duration;
    final position = widget.controller.value.position;
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  void _seekToProgress(double progress) {
    final duration = widget.controller.value.duration;
    final newPosition = Duration(
      milliseconds: (duration.inMilliseconds * progress).round(),
    );
    widget.controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final duration = widget.controller.value.duration;
    final buffered = widget.controller.value.buffered;

    final progress = _isDragging ? _dragProgress : _getCurrentProgress();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Account for horizontal padding in width calculations
        const horizontalPadding = 16.0;
        final barWidth = constraints.maxWidth - (horizontalPadding * 2);

        return GestureDetector(
          onTapDown: (details) => _onTapDown(details, barWidth),
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: (details) =>
              _onHorizontalDragUpdate(details, barWidth),
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Container(
            color: Colors.transparent,
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background bar - full width
                Positioned(
                  left: 0,
                  right: 0,
                  top: 10.5,
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                  ),
                ),
                // Buffered progress ranges
                ...buffered.map((range) {
                  final start =
                      range.start.inMilliseconds / duration.inMilliseconds;
                  final end =
                      range.end.inMilliseconds / duration.inMilliseconds;
                  // Clamp values to ensure they stay within bounds
                  final clampedStart = start.clamp(0.0, 1.0);
                  final clampedEnd = end.clamp(0.0, 1.0);
                  return Positioned(
                    left: barWidth * clampedStart,
                    top: 10.5,
                    child: Container(
                      height: widget.height,
                      width: barWidth * (clampedEnd - clampedStart),
                      decoration: BoxDecoration(
                        color: widget.bufferedColor,
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                  );
                }),
                // Played progress - starting from left
                Positioned(
                  left: 0,
                  top: 10.5,
                  child: Container(
                    height: widget.height,
                    width: barWidth * progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: widget.playedColor,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
