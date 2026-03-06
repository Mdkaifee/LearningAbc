import 'package:flutter/material.dart';

import '../components/app_asset_image.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppAssetImage('Aboutus', fit: BoxFit.cover),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.chevron_left, size: 30),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'About Us',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0A4279),
                      ),
                    ),
                    const Spacer(),
                    const AppAssetImage(
                      'elephantl_logo',
                      width: 62,
                      height: 62,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _infoCard(
                  title: 'Who We Are',
                  color: const Color(0xFFE6FFCB),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'ABC Adventure helps children learn alphabets through animals, animations, and sound.',
                          style: TextStyle(fontSize: 16, height: 1.35),
                        ),
                      ),
                      SizedBox(width: 10),
                      AppAssetImage('giraffe_about_us', width: 90, height: 120),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _infoCard(
                  title: 'What Your Child Learns',
                  color: const Color(0xFFFFF5C5),
                  child: const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ChipImage(name: 'AB', text: 'Letters A-Z'),
                      _ChipImage(
                        name: 'Animal_name_sound',
                        text: 'Animal sounds',
                      ),
                      _ChipImage(
                        name: 'Listnening_skill',
                        text: 'Listening skill',
                      ),
                      _ChipImage(name: 'safe', text: '100% safe'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _infoCard(
                  title: 'Languages',
                  color: const Color(0xFFFDFDFD),
                  child: const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FlagChip(text: 'English'),
                      _FlagChip(text: 'French'),
                      _FlagChip(text: 'Spanish'),
                      _FlagChip(text: 'Italian'),
                      _FlagChip(text: 'Portuguese'),
                      _FlagChip(text: 'Dutch'),
                      _FlagChip(text: 'German'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _infoCard(
                  title: 'Our Commitment',
                  color: const Color(0xFFFFF5C5),
                  child: const Column(
                    children: [
                      _CommitRow(image: 'safe', text: 'Safe for kids'),
                      _CommitRow(image: '13', text: 'No ads'),
                      _CommitRow(
                        image: '14',
                        text: 'Designed for early learners',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1D5687),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ChipImage extends StatelessWidget {
  const _ChipImage({required this.name, required this.text});

  final String name;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          AppAssetImage(name, width: 56, height: 56),
          const SizedBox(height: 4),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _CommitRow extends StatelessWidget {
  const _CommitRow({required this.image, required this.text});

  final String image;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AppAssetImage(image, width: 34, height: 34),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
