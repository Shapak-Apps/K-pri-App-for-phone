import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/profile_repository.dart';
import '../screens/avatar_camera_screen.dart';
import '../screens/preset_avatars_screen.dart';

class ProfileHeader extends StatefulWidget {
  final VoidCallback onEditBio;
  const ProfileHeader({
    super.key,
    required this.onEditBio,
  });
  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final _ctrl = TextEditingController();
  final _picker = ImagePicker();
  bool _editing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _startEdit() {
    _ctrl.text = ProfileRepository.instance.name;
    setState(() => _editing = true);
  }

  Future<void> _save() async {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    await ProfileRepository.instance.setName(v);
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _pickAvatar() async {
    final c = context.c, l10n = context.l10n, p = ProfileRepository.instance;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tile(c, Icons.photo_library_rounded, l10n.t('profile_gallery'), () async {
                Navigator.pop(ctx);
                final x = await _picker.pickImage(source: ImageSource.gallery,
                    maxWidth: 512, maxHeight: 512, imageQuality: 85);
                if (x != null && mounted) await p.saveAvatarFromPath(x.path);
              }),
              const SizedBox(height: 8),
              _tile(c, Icons.photo_camera_rounded, l10n.t('profile_camera'), () async {
                Navigator.pop(ctx);
                // ← Нативная камера вместо системной
                final path = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const AvatarCameraScreen()),
                );
                if (path != null && mounted) {
                  await p.saveAvatarFromPath(path);
                }
              }),
              const SizedBox(height: 8),
              _tile(c, Icons.emoji_emotions_rounded, l10n.t('profile_emoji'), () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PresetAvatarsScreen()));
              }),
              if (p.hasAvatar || p.avatarEmoji != null) ...[
                const SizedBox(height: 8),
                _tile(c, Icons.delete_outline_rounded, l10n.t('profile_remove_photo'), () async {
                  Navigator.pop(ctx);
                  await p.deleteAvatar();
                }, warn: true),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(AppColors c, IconData icon, String label, VoidCallback onTap,
      {bool warn = false}) {
    return Material(
      color: c.surfaceHi,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: warn ? c.warn : c.accent, size: 24),
              const SizedBox(width: 14),
              Text(label, style: TextStyle(
                  color: warn ? c.warn : c.text,
                  fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themedBtn({
    required String label,
    IconData? icon,
    double? width,
    double height = 44,
    double fontSize = 13,
    required VoidCallback onTap,
  }) {
    final c = context.c;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF0B0E14), Color(0xFF141B2E)]
                  : [c.accentDeep, c.accent],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? c.accent.withValues(alpha: 0.45) : c.accentDeep,
            ),
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: isDark ? 0.25 : 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: isDark ? c.accentHi : Colors.white, size: fontSize + 5),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? c.accentHi : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final p = ProfileRepository.instance;
    final hasName = p.name.isNotEmpty;

    Widget rightSection;

    if (_editing) {
      rightSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: l10n.t('profile_enter_name'),
                    hintStyle: TextStyle(color: c.faint),
                    filled: true,
                    fillColor: c.surface,
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _save(),
                ),
              ),
              const SizedBox(width: 8),
              _themedBtn(
                label: l10n.t('profile_save_name'),
                icon: Icons.check_rounded,
                height: 44,
                width: 110,
                onTap: _save,
              ),
              if (hasName) ...[
                const SizedBox(width: 4),
                Container(
                  width: 36,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.surfaceHi,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close_rounded, color: c.sub, size: 18),
                    onPressed: () => setState(() => _editing = false),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          _bioRow(c, l10n, p),
        ],
      );
    } else if (hasName) {
      rightSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: AppTheme.display(size: 20, color: c.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              _themedBtn(
                label: l10n.t('profile_change_name'),
                icon: Icons.edit_rounded,
                height: 36,
                fontSize: 11,
                onTap: _startEdit,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _bioRow(c, l10n, p),
        ],
      );
    } else {
      rightSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _themedBtn(
              label: l10n.t('profile_create_name'),
              icon: Icons.add_rounded,
              height: 42,
              onTap: _startEdit,
            ),
          ),
          const SizedBox(height: 10),
          _bioRow(c, l10n, p),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── АВАТАР СЛЕВА ──
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceHi,
                border: Border.all(color: c.line, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: p.hasAvatar
                  ? ClipOval(
                child: Image.file(
                  p.avatarFile,
                  key: ValueKey('avatar_${p.avatarVersion}'),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.person_rounded, color: c.accent, size: 48),
                ),
              )
                  : p.avatarEmoji != null
                  ? Center(
                  child: Text(p.avatarEmoji!,
                      style: const TextStyle(fontSize: 48)))
                  : Icon(Icons.person_rounded, color: c.accent, size: 48),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Material(
                color: c.accent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _pickAvatar, // ← Вызываем локальный метод
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: c.bg, width: 3),
                    ),
                    child: Icon(Icons.photo_camera_rounded,
                        color: c.bg, size: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // ── ПРАВАЯ ЧАСТЬ (имя + кнопка + био) ──
        Expanded(child: rightSection),
      ],
    );
  }

  Widget _bioRow(AppColors c, dynamic l10n, ProfileRepository p) {
    return GestureDetector(
      onTap: widget.onEditBio,
      child: Row(
        children: [
          Icon(Icons.edit_note_rounded, color: c.faint, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              p.bio.isEmpty ? l10n.t('profile_bio_hint') : p.bio,
              style: AppTheme.caption(
                  color: p.bio.isEmpty ? c.faint : c.sub, size: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}