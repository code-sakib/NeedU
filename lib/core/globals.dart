import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:needu/core/model_class.dart';

//Generals

bool isGuest = false;

//Firebase

final FirebaseAuth auth = FirebaseAuth.instance;

FirebaseFirestore  cloudDB = FirebaseFirestore.instance;

//Currentuser
late CurrentUser currentUser;

  
