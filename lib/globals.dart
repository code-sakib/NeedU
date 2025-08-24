

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

late final double ScreenHeight;
late final double ScreenWidth;

//Firebase

FirebaseFirestore  cloudDB = FirebaseFirestore.instance;