class Server {
  static const protocol = "https";
  // TODO: Configure your backend server hostname before deployment
  // See docs/DEVELOPER.md for backend infrastructure setup instructions
  static const String name = "api.example.com";
  static const int port = 443;
  static const String apiPath = "/api/v1/rides";

  /// Validates that the server configuration is properly set up.
  /// Returns true if valid, false if using placeholder values.
  static bool isConfigured() {
    return name != "api.example.com" && name.isNotEmpty;
  }

  /// Returns a user-friendly error message if server is not configured.
  static String getConfigurationError() {
    if (name == "api.example.com") {
      return "Server hostname not configured. Please update lib/server.dart before deployment.";
    }
    if (name.isEmpty) {
      return "Server hostname is empty. Please configure lib/server.dart.";
    }
    return "";
  }
}

