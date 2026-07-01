import 'package:flutter/material.dart';

/// Slide 1 – "Dress to impress"
class DressToImpressIllustration extends StatelessWidget {
  const DressToImpressIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285,
      child: Image.asset(
        'assets/images/onboarding/onboarding_1.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Slide 2 – "Virtual Fitting Room"
class VirtualFittingRoomIllustration extends StatelessWidget {
  const VirtualFittingRoomIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285,
      child: Image.asset(
        'assets/images/onboarding/onboarding_2.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Slide 3 – "Style me AI"
class StyleMeAIIllustration extends StatelessWidget {
  const StyleMeAIIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285,
      child: Image.asset(
        'assets/images/onboarding/onboarding_3.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
