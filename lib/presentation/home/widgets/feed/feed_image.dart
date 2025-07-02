import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';

class FeedImage extends StatelessWidget {
  const FeedImage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        child: Image.network(
          'https://images.unsplash.com/photo-1750924719065-b986e613f3a5?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHw3fHx8ZW58MHx8fHx8',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
