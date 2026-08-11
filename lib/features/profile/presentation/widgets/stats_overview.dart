import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/data/history_repository.dart';
import '../../data/profile_stats_service.dart';

class StatsOverview extends StatelessWidget {
  final HistoryRepository repo;
  const StatsOverview({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final lang = ProfileStatsService.getMostUsedLanguage(repo);
    final peak = ProfileStatsService.getPeakActivityHour(repo);
    final avg = ProfileStatsService.getAverageLength(repo);
    final top = ProfileStatsService.getTopPhrases(repo);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.t('profile_adv'),
              style: TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _tile(c, Icons.language_rounded, l10n.t('profile_top_lang'), lang)),
              const SizedBox(width: 10),
              Expanded(child: _tile(c, Icons.schedule_rounded, l10n.t('profile_peak'), peak)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _tile(c, Icons.straighten_rounded, l10n.t('profile_avg_len'), '$avg')),
              const SizedBox(width: 10),
              Expanded(child: _tile(c, Icons.translate_rounded, l10n.t('profile_translations'), '${ProfileStatsService.totalCount(repo)}')),
            ],
          ),
          if (top.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(l10n.t('profile_top_phrases'),
                style: TextStyle(color: c.sub, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            for (int i = 0; i < top.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text('${i + 1}.', style: TextStyle(color: c.accent, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(top[i], maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: c.text, fontSize: 13)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _tile(AppColors c, IconData ic, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceHi,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ic, color: c.accent, size: 18),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w800),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: TextStyle(color: c.faint, fontSize: 10)),
        ],
      ),
    );
  }
}

extension on HistoryRepository {
  int countSafe() {
    try {
      final dynamic d = this;
      final all = d.getAll();
      return all is List ? all.length : 0;
    } catch (_) {
      return 0;
    }
  }
}