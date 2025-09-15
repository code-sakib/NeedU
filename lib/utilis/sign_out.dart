import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:needu/core/globals.dart';

signOutButton(BuildContext context, [bool del = false]) {
  return // Sign Out Button
  SizedBox(
    child: OutlinedButton(
      onPressed: () async {
        if (isGuest) {
          isGuest = false;
        }

        await auth.signOut().then((v) async {
          if (del) {
            await auth.currentUser?.delete();
          }
          context.go('/');
        });
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 8),
          Text(
            !del ? 'Sign Out' : 'Delete User',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
