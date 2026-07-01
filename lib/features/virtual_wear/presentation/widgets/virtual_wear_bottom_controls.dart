import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'circular_action_button.dart';
import 'recommend_button.dart';

class VirtualWearBottomControls extends StatelessWidget {
  const VirtualWearBottomControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 18,
      right: 18,
      bottom: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularActionButton(
            icon: Icons.shopping_cart_outlined,
            onPressed: () => context.push('/saved-outfits'),
          ),
          const RecommendButton(),
          CircularActionButton(
            icon: Icons.share_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share virtual outfit')),
              );
            },
          ),
        ],
      ),
    );
  }
}
