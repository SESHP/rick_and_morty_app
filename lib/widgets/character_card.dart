import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/characters_provider.dart';
import '../providers/settings_provider.dart';
import '../services/translation_service.dart';
import '../screens/character_detail_screen.dart';

class CharacterCard extends StatefulWidget {
  final Character character;
  final int index;

  const CharacterCard({
    super.key,
    required this.character,
    this.index = 0,
  });

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isTapped = false;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Анимация появления с задержкой
    Future.delayed(Duration(milliseconds: 50 * (widget.index % 9)), () {
      if (mounted && !_hasAnimated) {
        _hasAnimated = true;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isTapped = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isTapped = false);
  }

  void _onTapCancel() {
    setState(() => _isTapped = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CharactersProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isFavorite = provider.isFavorite(widget.character.id);
    final t = (String text) => TranslationService.translate(text, settings.language);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    CharacterDetailScreen(character: widget.character),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: AnimatedScale(
            scale: _isTapped ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              decoration: BoxDecoration(
                color: settings.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: settings.isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Картинка
                  Expanded(
                    flex: 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                            tag: 'character_${widget.character.id}',
                            child: Stack(
                                fit: StackFit.expand,
                                children: [
                                CachedNetworkImage(
                                    imageUrl: widget.character.image,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                    color: settings.isDark ? Colors.grey[900] : Colors.grey[200],
                                    child: Center(
                                        child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: settings.themeColor.withOpacity(0.5),
                                        ),
                                    ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                    color: settings.isDark ? Colors.grey[900] : Colors.grey[200],
                                    child: Icon(
                                        Icons.error,
                                        color: settings.textTertiaryColor,
                                    ),
                                    ),
                                ),
                                Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 40,
                                    child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                            Colors.transparent,
                                            settings.cardColor,
                                        ],
                                        ),
                                    ),
                                    ),
                                ),
                                ],
                            ),
                            ),
                        // Статус
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _StatusDot(
                            status: widget.character.status,
                            translatedStatus: t(widget.character.status),
                          ),
                        ),
                        // Звёздочка
                        Positioned(
                          top: 4,
                          right: 4,
                          child: _FavoriteButton(
                            isFavorite: isFavorite,
                            color: settings.themeColor,
                            onPressed: () => provider.toggleFavorite(widget.character),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Текст
                  Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                            widget.character.name,
                            style: TextStyle(
                                color: settings.textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                            t(widget.character.species),
                            style: TextStyle(
                                color: settings.textSecondaryColor,
                                fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                            widget.character.location,
                            style: TextStyle(
                                color: settings.textTertiaryColor,
                                fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            ),
                        ],
                        ),
                    ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  final String translatedStatus;

  const _StatusDot({
    required this.status,
    required this.translatedStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'alive':
        statusColor = const Color(0xFF34C759);
        break;
      case 'dead':
        statusColor = const Color(0xFFFF3B30);
        break;
      default:
        statusColor = const Color(0xFFFF9500);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            translatedStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final Color color;
  final VoidCallback onPressed;

  const _FavoriteButton({
    required this.isFavorite,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          widget.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          color: widget.isFavorite ? widget.color : Colors.white70,
          size: 24,
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}