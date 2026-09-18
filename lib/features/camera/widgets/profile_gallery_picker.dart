import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/camera_repository.dart';

/// Simple grid picker over photos saved by the camera module.
/// Returns the selected file path via [Navigator.pop].
class ProfileGalleryPicker extends StatelessWidget {
  const ProfileGalleryPicker();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: Text(
          'Галерея',
          style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: c.text),
      ),
      body: ListenableBuilder(
        listenable: CameraRepository.instance,
        builder: (context, _) {
          final all = CameraRepository.instance.getAll();
          if (all.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_outlined, color: c.faint, size: 64),
                  const SizedBox(height: 12),
                  Text('Нет сохраненных фото', style: TextStyle(color: c.sub)),
                  const SizedBox(height: 8),
                  Text(
                    'Сначала сделайте снимок в камере',
                    style: TextStyle(color: c.faint, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: all.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => Navigator.pop(context, all[i].path),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(all[i].path), fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}
