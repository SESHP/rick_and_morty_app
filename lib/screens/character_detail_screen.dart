import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/characters_provider.dart';
import '../providers/settings_provider.dart';
import '../services/translation_service.dart';

class CharacterDetailScreen extends StatefulWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CharactersProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isFavorite = provider.isFavorite(widget.character.id);
    final t = (String text) => TranslationService.translate(text, settings.language);

    return Scaffold(
      backgroundColor: settings.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: settings.backgroundColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _AnimatedFavoriteButton(
                  isFavorite: isFavorite,
                  color: settings.themeColor,
                  onPressed: () => provider.toggleFavorite(widget.character),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                    tag: 'character_${widget.character.id}',
                    child: Stack(
                    fit: StackFit.expand,
                    children: [
                        CachedNetworkImage(
                        imageUrl: widget.character.image,
                        fit: BoxFit.cover,
                        ),
                        DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                                Colors.transparent,
                                Colors.transparent,
                                settings.backgroundColor.withOpacity(0.8),
                                settings.backgroundColor,
                            ],
                            ),
                        ),
                        ),
                    ],
                    ),
                ),
                ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.character.name,
                              style: TextStyle(
                                color: settings.textColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          _StatusBadge(
                            status: widget.character.status,
                            translatedStatus: t(widget.character.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${t(widget.character.species)} • ${t(widget.character.gender)}',
                        style: TextStyle(
                          color: settings.textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _AnimatedInfoCard(
                        icon: Icons.location_on_outlined,
                        title: t('Location'),
                        value: widget.character.location,
                        settings: settings,
                        delay: 0,
                      ),
                      const SizedBox(height: 12),
                      _AnimatedInfoCard(
                        icon: Icons.public_outlined,
                        title: t('Origin'),
                        value: widget.character.origin,
                        settings: settings,
                        delay: 100,
                      ),
                      const SizedBox(height: 12),
                      _AnimatedInfoCard(
                        icon: Icons.category_outlined,
                        title: t('Type'),
                        value: t(widget.character.type),
                        settings: settings,
                        delay: 200,
                      ),
                      const SizedBox(height: 12),
                      _AnimatedInfoCard(
                        icon: Icons.movie_outlined,
                        title: t('Episodes'),
                        value: '${widget.character.episodeCount}',
                        settings: settings,
                        delay: 300,
                      ),
                      const SizedBox(height: 32),

                      Center(
                        child: Text(
                          'ID: ${widget.character.id}',
                          style: TextStyle(
                            color: settings.textTertiaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String translatedStatus;

  const _StatusBadge({required this.status, required this.translatedStatus});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'alive':
        color = const Color(0xFF34C759);
        break;
      case 'dead':
        color = const Color(0xFFFF3B30);
        break;
      default:
        color = const Color(0xFFFF9500);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            translatedStatus,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedInfoCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final SettingsProvider settings;
  final int delay;

  const _AnimatedInfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.settings,
    required this.delay,
  });

  @override
  State<_AnimatedInfoCard> createState() => _AnimatedInfoCardState();
}

class _AnimatedInfoCardState extends State<_AnimatedInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: 300 + widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.settings.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.settings.isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.settings.themeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.settings.themeColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.settings.textSecondaryColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value,
                      style: TextStyle(
                        color: widget.settings.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedFavoriteButton({
    required this.isFavorite,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<_AnimatedFavoriteButton>
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
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AnimatedFavoriteButton oldWidget) {
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
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: widget.isFavorite ? widget.color : Colors.white,
            size: 22,
          ),
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}