// data_state.dart (made async to properly handle futures, improved error catching)

import 'package:firebase_auth/firebase_auth.dart'; // For specific FirebaseAuthException
// If needed for FirebaseException
import 'package:needu/utilis/snackbar.dart';

class DataState {
  // Async runner for operations, catches exceptions and shows snackbars
  // Usage: await DataState.run(() async { await someAsyncOperation(); });
  static Future<void> run(Future<void> Function() funcToRun) async {
    try {
      await funcToRun();
    } on FirebaseAuthException catch (e) {
      // Specific handling for auth errors
      Utilis.showSnackBar('${e.message}', isErr: true);
    } on FirebaseException catch (e) {
      // General Firebase errors
      Utilis.showSnackBar('${e.message}', isErr: true);
    } catch (e) {
      // Generic errors
      Utilis.showSnackBar(e.toString(), isErr: true);
    }
  }
}