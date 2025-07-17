/// Utility class for generating time-based greetings
class GreetingHelper {
  /// Returns a greeting message based on the current time
  /// 
  /// Time ranges:
  /// - 5:00 AM - 11:59 AM: Good Morning
  /// - 12:00 PM - 4:59 PM: Good Afternoon  
  /// - 5:00 PM - 8:59 PM: Good Evening
  /// - 9:00 PM - 4:59 AM: Good Night
  static String getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  /// Returns a greeting message with emoji based on the current time
  static String getTimeBasedGreetingWithEmoji() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning ☀️";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon 🌤️";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening 🌅";
    } else {
      return "Good Night 🌙";
    }
  }

  /// Returns a more detailed greeting with time context
  static String getDetailedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 8) {
      return "Good Morning! Early bird";
    } else if (hour >= 8 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 14) {
      return "Good Afternoon! Lunch time";
    } else if (hour >= 14 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 19) {
      return "Good Evening";
    } else if (hour >= 19 && hour < 21) {
      return "Good Evening! Dinner time";
    } else if (hour >= 21 && hour < 23) {
      return "Good Night! Relax time";
    } else {
      return "Good Night! Sweet dreams";
    }
  }

  /// Returns appropriate greeting icon based on time
  static String getGreetingIcon() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return "☀️"; // Sun for morning
    } else if (hour >= 12 && hour < 17) {
      return "🌤️"; // Partly cloudy for afternoon
    } else if (hour >= 17 && hour < 21) {
      return "🌅"; // Sunset for evening
    } else {
      return "🌙"; // Moon for night
    }
  }

  /// Returns greeting color based on time of day
  static int getGreetingColor() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 0xFFFFA726; // Orange for morning
    } else if (hour >= 12 && hour < 17) {
      return 0xFF42A5F5; // Blue for afternoon
    } else if (hour >= 17 && hour < 21) {
      return 0xFFFF7043; // Deep orange for evening
    } else {
      return 0xFF5C6BC0; // Indigo for night
    }
  }

  /// Returns a motivational message based on time
  static String getMotivationalMessage() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return "Start your day with a smile!";
    } else if (hour >= 12 && hour < 17) {
      return "Keep up the great work!";
    } else if (hour >= 17 && hour < 21) {
      return "Almost done for the day!";
    } else {
      return "Time to rest and recharge!";
    }
  }
}
