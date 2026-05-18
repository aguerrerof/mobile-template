import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? imageString;
  final VoidCallback onPressed;
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.onPressed,
    this.imageString,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 40,
                child: ClipOval(
                  child: Image.network(
                    imageString ?? "",
                    fit: BoxFit.contain,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.contain,
                        width: 80,
                        height: 80,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_sharp,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                email,
                style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }
}
