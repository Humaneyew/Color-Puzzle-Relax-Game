import 'dart:async';

/// Simple stub that mimics an rewarded advertisement flow.
class AdService {
  const AdService();

  /// Pretends to show a rewarded advertisement.
  ///
  /// Returns `true` when the simulated ad was `watched` completely.
  Future<bool> showRewardedAd() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return true;
  }
}
