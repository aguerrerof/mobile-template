import 'package:firebase_auth/firebase_auth.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  void trackEvent(String eventName, {Map<String, Object>? properties}) {
    Posthog().capture(eventName: eventName, properties: properties);
  }

  void trackScreen(String screen) {
    Posthog().screen(screenName: screen);
  }

  void identifyUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    Posthog().identify(
      userId: user.uid,
      userProperties: {
        'email': user.email ?? '',
        'name': user.displayName ?? '',
      },
    );
  }

  void reset() {
    Posthog().reset();
  }
}
