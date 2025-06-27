// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DynamicLinksService {
//   static const String _savedEmailKey = 'saved_email_for_link';
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;

//   /// Initialize dynamic links handling
//   Future<void> initDynamicLinks() async {
//     // Handle app opened from dynamic link when app was terminated
//     final PendingDynamicLinkData? data = await _dynamicLinks.getInitialLink();
//     final Uri? deepLink = data?.link;

//     if (deepLink != null) {
//       await _handleEmailLink(deepLink);
//     }

//     // Handle dynamic links when app is already running
//     _dynamicLinks.onLink.listen((dynamicLinkData) async {
//       final Uri deepLink = dynamicLinkData.link;
//       await _handleEmailLink(deepLink);
//     });
//   }

//   /// Handle email link authentication
//   Future<void> _handleEmailLink(Uri deepLink) async {
//     try {
//       // Check if this is an email link (contains oobCode parameter)
//       final oobCode = deepLink.queryParameters['oobCode'];

//       if (oobCode != null) {
//         final savedEmail = await _getSavedEmail();
//         if (savedEmail != null) {
//           await _auth.signInWithEmailLink(
//             email: savedEmail,
//             emailLink: deepLink.toString(),
//           );
//           // Clear saved email after successful sign in
//           await clearSavedEmail();
//         }
//       }
//     } catch (e) {
//       print('Error handling email link: $e');
//     }
//   }

//   /// Save email for later use with email link
//   Future<void> saveEmailForLink(String email) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_savedEmailKey, email);
//   }

//   /// Get saved email for email link authentication
//   Future<String?> _getSavedEmail() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_savedEmailKey);
//   }

//   /// Clear saved email
//   Future<void> clearSavedEmail() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_savedEmailKey);
//   }
// }
