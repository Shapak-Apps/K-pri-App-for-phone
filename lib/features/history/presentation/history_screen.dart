import 'package:flutter/material.dart';
import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/history_repository.dart';
import 'widgets/history_tile.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryRepository repo;
  const HistoryScreen({super.key, required this.repo});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _tab = 0;
  String _q = '';
  List _list() {
    final src = _tab == 0 ? widget.repo.getAll() : widget.repo.getFavorites();
    if (_q.isEmpty) return src;
    final q = _q.toLowerCase();
    return src
        .where(
          (e) =>
              e.source.toLowerCase().contains(q) ||
              e.result.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c, l10n = context.l10n;
    final list = _list();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          child: Row(
            children: [
              Text(
                l10n.t('nav_history'),
                style: AppTheme.display(size: 22, color: c.text),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  await widget.repo.clear();
                  setState(() {});
                },
                icon: Icon(Icons.delete_sweep_rounded, color: c.warn),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.line),
            ),
            child: Row(
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _tab == i
                              ? c.accent.withValues(alpha: 0.14)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            i == 0 ? l10n.t('history') : l10n.t('favorites'),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _tab == i ? c.accent : c.sub,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: TextField(
            onChanged: (v) => setState(() => _q = v),
            style: TextStyle(color: c.text),
            decoration: InputDecoration(
              hintText: l10n.t('search'),
              hintStyle: TextStyle(color: c.faint),
              prefixIcon: Icon(Icons.search_rounded, color: c.sub),
              filled: true,
              fillColor: c.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(
                    _tab == 0 ? l10n.t('no_history') : l10n.t('no_favorites'),
                    style: AppTheme.caption(color: c.faint),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: list.length,
                  itemBuilder: (_, i) => HistoryTile(
                    entry: list[i],
                    onTap: () {},
                    onFav: () async {
                      await widget.repo.toggleFavorite(list[i].id);
                      setState(() {});
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
