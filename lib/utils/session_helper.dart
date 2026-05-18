class Session {
  static String? screenPostLoggin;
  static String? screenParent;
  static int? pendingHomeTabIndex;

  static void clear() {
    screenPostLoggin = null;
    screenParent = null;
    pendingHomeTabIndex = null;
  }
}
