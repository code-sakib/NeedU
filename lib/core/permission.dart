// import 'package:needu/utilis/snackbar.dart';
// import 'package:permission_handler/permission_handler.dart';

// class PermissionHandler {
//   static Future<void> initPermissions() async {
//     await Permission.microphone.request().then((v) {
//       print('Microphone permission status: $v');
//     });
//   }

//   static Future<bool> isAudioPermitted() async {
//     var status = await Permission.microphone.status;

//     if (status.isDenied || status.isRestricted || status.isLimited) {
//       // Ask for permission
//       status = await Permission.microphone.request();
//     }

//     if (status.isGranted) {
//       // ✅ Permission already granted
//       return true;
//     } else if (status.isPermanentlyDenied) {
//       // ❌ User has permanently denied permission
//       Utilis.showSnackBar(
//         "Permission is required to trigger services. Open settings to enable.",
//         isErr: false,
//       );
//       // await openAppSettings();
//       return false;
//     } else {
//       // ❌ Permission denied (but not permanently)
//       Utilis.showSnackBar(
//         "Permission2 is required to trigger services. Open settings to enable.",
//         isErr: false,
//       );
//       return false;
//     }
//   }
// }
