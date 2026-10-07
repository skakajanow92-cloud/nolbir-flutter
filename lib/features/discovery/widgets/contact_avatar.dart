import 'package:flutter/material.dart';

class ContactAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final double size;

  const ContactAvatar({
    super.key,
    required this.name,
    this.avatarUrl = "",
    this.isOnline = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Container(
              width: size,
              height: size,
              color: Colors.white.withValues(alpha: 0.08),
              alignment: Alignment.center,
              child: avatarUrl.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Image.network(avatarUrl, fit: BoxFit.cover),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.26,
                height: size * 0.26,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF121212), width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
