import 'package:flutter/material.dart';

import '../../../data/models/app_user.dart';

class ProfileHeader extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onEditPhoto;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 55,
                          color: Colors.white,
                        )
                      : null,
                ),

                if (onEditPhoto != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: onEditPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              user.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Chip(
              avatar: const Icon(
                Icons.badge,
                size: 18,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
              label: Text(
                user.role,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              user.email,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}