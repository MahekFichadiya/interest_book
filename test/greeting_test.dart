import 'package:flutter_test/flutter_test.dart';
import 'package:interest_book/Utils/greeting_helper.dart';

void main() {
  group('GreetingHelper Tests', () {
    test('should return correct greeting for different times', () {
      // Note: These tests demonstrate the logic, but actual results depend on current time
      
      // Test that the function returns a valid greeting
      final greeting = GreetingHelper.getTimeBasedGreeting();
      expect(greeting, isNotEmpty);
      expect(['Good Morning', 'Good Afternoon', 'Good Evening', 'Good Night'].contains(greeting), true);
    });

    test('should return greeting with emoji', () {
      final greetingWithEmoji = GreetingHelper.getTimeBasedGreetingWithEmoji();
      expect(greetingWithEmoji, isNotEmpty);
      expect(greetingWithEmoji, contains(RegExp(r'[☀️🌤️🌅🌙]')));
    });

    test('should return valid greeting icon', () {
      final icon = GreetingHelper.getGreetingIcon();
      expect(icon, isNotEmpty);
      expect(['☀️', '🌤️', '🌅', '🌙'].contains(icon), true);
    });

    test('should return valid greeting color', () {
      final color = GreetingHelper.getGreetingColor();
      expect(color, isA<int>());
      expect(color, greaterThan(0));
    });

    test('should return motivational message', () {
      final message = GreetingHelper.getMotivationalMessage();
      expect(message, isNotEmpty);
      expect(message.length, greaterThan(10));
    });

    test('should return detailed greeting', () {
      final detailedGreeting = GreetingHelper.getDetailedGreeting();
      expect(detailedGreeting, isNotEmpty);
      expect(detailedGreeting, contains('Good'));
    });
  });

  group('Time-based Logic Demonstration', () {
    test('demonstrates different greetings throughout the day', () {
      print('\n=== Time-based Greeting Examples ===');
      
      // Simulate different times of day
      final timeExamples = [
        {'hour': 6, 'description': '6:00 AM (Early Morning)'},
        {'hour': 10, 'description': '10:00 AM (Morning)'},
        {'hour': 13, 'description': '1:00 PM (Afternoon)'},
        {'hour': 16, 'description': '4:00 PM (Late Afternoon)'},
        {'hour': 18, 'description': '6:00 PM (Evening)'},
        {'hour': 20, 'description': '8:00 PM (Late Evening)'},
        {'hour': 23, 'description': '11:00 PM (Night)'},
        {'hour': 2, 'description': '2:00 AM (Late Night)'},
      ];

      for (final example in timeExamples) {
        final hour = example['hour'] as int;
        final description = example['description'] as String;
        
        String greeting;
        String icon;
        
        if (hour >= 5 && hour < 12) {
          greeting = "Good Morning";
          icon = "☀️";
        } else if (hour >= 12 && hour < 17) {
          greeting = "Good Afternoon";
          icon = "🌤️";
        } else if (hour >= 17 && hour < 21) {
          greeting = "Good Evening";
          icon = "🌅";
        } else {
          greeting = "Good Night";
          icon = "🌙";
        }
        
        print('$description → $greeting, $icon');
      }
      
      print('=== Current Time Greeting ===');
      print('Current: ${GreetingHelper.getTimeBasedGreeting()}, ${GreetingHelper.getGreetingIcon()}');
      print('With Emoji: ${GreetingHelper.getTimeBasedGreetingWithEmoji()}');
      print('Detailed: ${GreetingHelper.getDetailedGreeting()}');
      print('Motivational: ${GreetingHelper.getMotivationalMessage()}');
    });
  });
}
