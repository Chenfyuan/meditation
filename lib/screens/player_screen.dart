import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/player_orb.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final posMin = player.position.inMinutes.toString().padLeft(2, '0');
    final posSec = (player.position.inSeconds % 60).toString().padLeft(2, '0');
    final durMin = player.duration.inMinutes.toString().padLeft(2, '0');
    final durSec = (player.duration.inSeconds % 60).toString().padLeft(2, '0');

    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5A463A), Color(0xFF33271F), Color(0xFF241B15)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return _buildDesktopLayout(
                  context,
                  player,
                  posMin,
                  posSec,
                  durMin,
                  durSec,
                );
              }

              return _buildMobileLayout(
                context,
                player,
                constraints,
                posMin,
                posSec,
                durMin,
                durSec,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    PlayerProvider player,
    BoxConstraints constraints,
    String posMin,
    String posSec,
    String durMin,
    String durSec,
  ) {
    return Stack(
      children: [
        Positioned(
          top: 90,
          left: 0,
          right: 0,
          child: Center(child: _buildGlow(size: 340)),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                _buildTopBar(player),
                const SizedBox(height: 36),
                const SizedBox(height: 8),
                PlayerOrb(isPlaying: player.isPlaying),
                const SizedBox(height: 44),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _buildMeta(player, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 34),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: _buildProgress(player, posMin, posSec, durMin, durSec),
                ),
                const SizedBox(height: 30),
                _buildControls(player),
                const SizedBox(height: 36),
                _buildAmbientBadge(player),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    PlayerProvider player,
    String posMin,
    String posSec,
    String durMin,
    String durSec,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
      child: Column(
        children: [
          _buildTopBar(player),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: _buildGlow(size: 430),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scale: 1.18,
                          child: PlayerOrb(isPlaying: player.isPlaying),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(34),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(12),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: Colors.white.withAlpha(18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '沉入此刻',
                          style: AppFonts.sans(
                            fontSize: 12,
                            letterSpacing: 1.8,
                            color: AppColors.white.withAlpha(166),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildMeta(player, textAlign: TextAlign.left),
                        const SizedBox(height: 30),
                        _buildProgress(player, posMin, posSec, durMin, durSec),
                        const SizedBox(height: 34),
                        _buildControls(player),
                        const Spacer(),
                        _buildAmbientBadge(player),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(PlayerProvider player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: player.collapse,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.white,
              size: 28,
            ),
          ),
          Text(
            '正在播放',
            style: AppFonts.sans(
              fontSize: 13,
              letterSpacing: 3,
              color: AppColors.white.withAlpha(179),
            ),
          ),
          IconButton(
            onPressed: player.reset,
            icon: const Icon(Icons.close, color: AppColors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildMeta(PlayerProvider player, {required TextAlign textAlign}) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.left
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          player.currentTitle,
          textAlign: textAlign,
          style: AppFonts.serif(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${player.currentInstructor} · 引导冥想',
          textAlign: textAlign,
          style: AppFonts.sans(
            fontSize: 14,
            color: AppColors.white.withAlpha(166),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(
    PlayerProvider player,
    String posMin,
    String posSec,
    String durMin,
    String durSec,
  ) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: AppColors.white,
            inactiveTrackColor: AppColors.white.withAlpha(51),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: player.progress.clamp(0.0, 1.0),
            onChanged: (v) => player.seekTo(v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$posMin:$posSec',
                style: AppFonts.sans(
                  fontSize: 13,
                  color: AppColors.white.withAlpha(153),
                ),
              ),
              Text(
                '$durMin:$durSec',
                style: AppFonts.sans(
                  fontSize: 13,
                  color: AppColors.white.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(PlayerProvider player) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.skip_previous,
          color: AppColors.white.withAlpha(217),
          size: 32,
        ),
        const SizedBox(width: 34),
        GestureDetector(
          onTap: player.togglePlay,
          child: Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                player.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.darkBg,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(width: 34),
        Icon(Icons.skip_next, color: AppColors.white.withAlpha(217), size: 32),
      ],
    );
  }

  Widget _buildAmbientBadge(PlayerProvider player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(31),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '背景音景 · ${player.ambientSound}',
            style: AppFonts.sans(
              fontSize: 13,
              color: AppColors.white.withAlpha(217),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [const Color(0xFFCAA074).withAlpha(120), Colors.transparent],
          stops: const [0.0, 0.68],
        ),
      ),
    );
  }
}
