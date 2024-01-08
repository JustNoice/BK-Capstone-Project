import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final void Function()? onTap;

  LikeButton({super.key, required this.isLiked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 13, // Sesuaikan ukuran container sesuai kebutuhan
        height: 13, // Sesuaikan ukuran container sesuai kebutuhan
        child: Icon(
          isLiked ? Icons.thumb_up : Icons.thumb_up,
          color: isLiked ? Color.fromARGB(255, 9, 140, 206) : Colors.grey,
        ),
     ),
);
}
}