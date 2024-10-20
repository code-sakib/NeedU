import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fj2/features/trigger/domain/contacts.dart';
import 'package:fj2/features/trigger/presentation/profile.dart';
import 'package:fj2/features/trigger/presentation/settings.dart';
import 'package:fj2/features/utilis&configs/get_it.dart';
import 'package:fj2/features/utilis&configs/scroll_behaviour.dart';
import 'package:fj2/features/utilis&configs/snackbar.dart';
import 'package:flutter/material.dart';
import 'features/trigger/presentation/trigger_page.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: ConstantScrollBehavior(),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 1;
  List pages = [ const ProfilePage(), const TriggerPage(), const SettingsPage()];
  bool aboutCount = true;

  onTap(int index) {
    if (index != selectedIndex) {
      setState(() {
        selectedIndex = index;
        aboutCount = false;
      });
    } else {
      if (index == 1) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                  contentPadding: EdgeInsets.all(15), content: AddContacts());
            });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SelectedContacts.isPermitted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      resizeToAvoidBottomInset: false,
      key: AppSnackBar.messengerKey,
      bottomNavigationBar: CurvedNavigationBar(
        index: 1,
        height: 65,
        backgroundColor: const Color(0xFFACD0AD),
        color: const Color.fromARGB(255, 120, 180, 120),
        animationDuration: const Duration(milliseconds: 500),
        items: const [
          Icon(Icons.person_2_rounded),
          Icon(Icons.add),
          Icon(Icons.settings),
        ],
        onTap: (value) {
          onTap(value);
        },
      ),
      backgroundColor: const Color.fromARGB(255, 172, 208, 173),
    );
  }
}
