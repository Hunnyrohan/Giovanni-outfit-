import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';

/// Displays the user's real profile picture when one is set. When there is
/// no picture (e.g. a freshly created account), falls back to a neutral
/// initial-letter avatar instead of a stock photo, matching how real apps
/// (Gmail, Slack, etc.) represent an empty profile picture.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.imageUrl,
    required this.name,
    this.size = 44,
    this.backgroundColor = const Color(0xff3a3a3a),
    this.textColor = Colors.white,
    super.key,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  String get _initial {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? '' : trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiConstants.resolveMediaUrl(imageUrl);
    final hasImage = resolvedUrl != null && resolvedUrl.isNotEmpty;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: resolvedUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _Fallback(
                  initial: _initial,
                  size: size,
                  backgroundColor: backgroundColor,
                  textColor: textColor,
                ),
                errorWidget: (context, url, error) => _Fallback(
                  initial: _initial,
                  size: size,
                  backgroundColor: backgroundColor,
                  textColor: textColor,
                ),
              )
            : _Fallback(
                initial: _initial,
                size: size,
                backgroundColor: backgroundColor,
                textColor: textColor,
              ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.initial,
    required this.size,
    required this.backgroundColor,
    required this.textColor,
  });

  final String initial;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Center(
        child: initial.isNotEmpty
            ? Text(
                initial,
                style: TextStyle(
                  color: textColor,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(Icons.person_rounded, color: textColor, size: size * 0.58),
      ),
    );
  }
}
