import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/camera_photo_model.dart';

/// Square-ish thumbnail of a saved [CameraPhoto] with an optional
/// language badge in the top-right corner.
class CameraGalleryCard extends StatelessWidget {
  final CameraPhoto photo;
  final VoidCallback onTap;
  const CameraGalleryCard({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surfaceHi,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(photo.path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: c.faint,
                    size: 32,
                  ),
                ),
              ),
            ),
            if (photo.translations.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    photo.translations.keys.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
