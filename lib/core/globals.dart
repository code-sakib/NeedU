import 'package:firebase_auth/firebase_auth.dart';

//Generals

bool isGuest = false;

//Firebase

final FirebaseAuth auth = FirebaseAuth.instance;
late User currentUser;
