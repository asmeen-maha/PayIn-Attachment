import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../data/models/access_flag.dart';

/// Logged-in user's code, name and photo.
class UserBadge extends StatelessWidget {
  const UserBadge({super.key, required this.user});

  final AccessFlag? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user?.code ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(user?.name ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.brown.shade100,
            child: ClipOval(child: _photo()),
          ),
        ],
      ),
    );
  }

  Widget _photo() {
    return Image.network(
      ApiConfig.staffPhotoUrl(user?.code ?? ''),
      fit: BoxFit.cover,
      width: 40,
      height: 40,
      errorBuilder: (_, __, ___) => const Icon(Icons.person_outline, color: Colors.brown),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.brown.shade300),
              ),
            ),
    );
  }
}
