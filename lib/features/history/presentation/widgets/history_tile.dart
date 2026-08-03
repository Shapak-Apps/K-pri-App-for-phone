import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/history_models.dart';
import '../../../translate/data/languages.dart';

class HistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap, onFav;
  const HistoryTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _chip(c, AppLanguages.nameOf(entry.from)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: c.faint,
                    ),
                  ),
                  _chip(c, AppLanguages.nameOf(entry.to), accent: true),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onFav,
                    icon: Icon(
                      entry.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: entry.isFavorite ? c.accent : c.faint,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.source,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, color: c.text),
              ),
              const SizedBox(height: 4),
              Text(
                entry.result,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: c.accent, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(AppColors c, String t, {bool accent = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: (accent ? c.accent : c.sub).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: (accent ? c.accent : c.sub).withValues(alpha: 0.25),
      ),
    ),
    child: Text(
      t,
      style: AppTheme.label(size: 9, color: accent ? c.accent : c.sub),
    ),
  );
}
