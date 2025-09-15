import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:needu/cloud_db.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/features/audio/emergency_contacts.dart';
import 'package:needu/features/auth/auth_services.dart';
import 'package:needu/utilis/sign_out.dart';
import 'package:needu/utilis/snackbar.dart';
import 'package:needu/wallet_page.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/utilis/size_config.dart';
import 'package:permission_handler/permission_handler.dart';

// Reusable SectionHeader widget
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onActionPressed;
  final String? tooltip;
  final IconData? actionIcon;
  final Widget? actionWidget;

  const SectionHeader({
    super.key,
    required this.title,
    this.onActionPressed,
    this.tooltip,
    this.actionIcon,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: SizeConfig.sectionTitle),
        if (onActionPressed != null && actionIcon != null)
          IconButton(
            onPressed: onActionPressed,
            icon: Icon(actionIcon, semanticLabel: tooltip),
            tooltip: tooltip,
          ),
        if (actionWidget != null)
          Padding(
            padding: EdgeInsets.all(SizeConfig.defaultIconSize),
            child: actionWidget,
          ),
      ],
    );
  }
}

// Reusable AppButton widget
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : SizedBox.shrink(),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.screenHeight * 0.02,
          horizontal: SizeConfig.screenWidth * 0.04,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // // Sample dynamic data for emergency contacts

  // void addContact(String name, String phone) {
  //   setState(() {
  //     emergencyContacts.value.add({'name': name, 'phone': phone});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: SizeConfig.screenVPadding,
              horizontal: SizeConfig.screenHPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.go('/sos_page'),
                      icon: Icon(Icons.arrow_back),
                    ),
                    Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.paddingLarge,
                            vertical: SizeConfig.paddingSmall,
                          ),
                          child: CircleAvatar(
                            radius: SizeConfig.screenWidth * 0.15,
                            backgroundColor: isGuest
                                ? Theme.of(context).colorScheme.primary
                                : thisUser?.profilePhotoUrl == null
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            backgroundImage:
                                !isGuest && thisUser?.profilePhotoUrl != null
                                ? NetworkImage(thisUser!.profilePhotoUrl!)
                                : null,
                            child: isGuest
                                ? Icon(
                                    Icons.person_outlined,
                                    size: SizeConfig.iconLarge,
                                    semanticLabel: 'Profile Picture',
                                  )
                                : thisUser!.profilePhotoUrl == null
                                ? Icon(
                                    Icons.person_outlined,
                                    size: SizeConfig.iconLarge,
                                    semanticLabel: 'Profile Picture',
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          left: SizeConfig.screenWidth / 2.6,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // Profile Name
                Text(
                  '${isGuest ? 'Guest User' : thisUser?.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Free Plan',
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // Emergency Contacts
                isGuest
                    ? guestEcCard(context)
                    : EmergencyContacts(toUpdateContacts: true),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // Permissions
                SectionHeader(
                  title: 'Permissions',
                  onActionPressed: () {
                    openAppSettings();
                  },
                  actionIcon: Icons.edit_outlined,
                  tooltip: 'Edit Permissions',
                ),
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.paddingSmall,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.mic_outlined,
                              semanticLabel: 'Microphone Permission',
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Audio Access',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  'Required for emergency audio services   ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.paddingSmall,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              semanticLabel: 'Location Permission',
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location Access',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  'Required for emergency location services',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // Pricing & Wallet
                const PricingWalletWidget(),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // Key Features
                const KeyFeaturesWidget(),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // About Version
                const AboutVersionWidget(),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                signOutButton(context),

                SizedBox(height: SizeConfig.screenHeight * 0.03),
                signOutButton(context, true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PricingWalletWidget extends StatelessWidget {
  const PricingWalletWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pricing & Wallet', style: SizeConfig.sectionTitle),
        SizedBox(height: SizeConfig.defaultHeight2),
        _buildPricingTable(),
        SizedBox(height: SizeConfig.defaultHeight2),
        _buildManageWalletButton(context),
      ],
    );
  }

  Widget _buildPricingTable() {
    final List<PricingPlan> plans = [
      PricingPlan(
        name: 'Starter Plan',
        features: '3 Emergency Services',
        price: '\$0',
      ),
      PricingPlan(
        name: 'Pro Plan',
        features: 'Per Service Called',
        price: '\$1',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('Plan'),
                _buildHeaderCell('Features'),
                _buildHeaderCell('Price'),
              ],
            ),
          ),
          ...plans.map(
            (plan) => Column(
              children: [
                Row(
                  children: [
                    _buildDataCell(plan.name),
                    _buildDataCell(plan.features),
                    _buildDataCell(plan.price),
                  ],
                ),
                if (plan != plans.last)
                  Container(
                    height: 1,
                    color: AppColors.border,
                    margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.paddingMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(SizeConfig.paddingSmall),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeConfig.screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(SizeConfig.paddingSmall),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeConfig.screenWidth * 0.04,
            fontWeight: FontWeight.w400,
            color: AppColors.text,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildManageWalletButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const WalletScreen()),
            );
            print('Manage Wallet tapped');
          },
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.paddingSmall),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: SizeConfig.screenWidth * 0.06,
                  semanticLabel: 'Manage Wallet',
                ),
                SizedBox(width: SizeConfig.paddingMedium),
                Expanded(
                  child: Text(
                    'Manage Wallet',
                    style: TextStyle(
                      fontSize: SizeConfig.screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: SizeConfig.screenWidth * 0.06,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PricingPlan {
  final String name;
  final String features;
  final String price;

  PricingPlan({
    required this.name,
    required this.features,
    required this.price,
  });
}

class KeyFeaturesWidget extends StatelessWidget {
  static const List<String> features = [
    'Add up to 3 emergency contacts with phone verification',
    'Press and hold SOS button for 3 seconds to activate',
    'Your location and 10s audio are sent via SMS',
    'App flashes green and closes automatically for safety',
    'Unlike native alerts that make alarm sounds, RescueMe stays silent',
    'Perfect for situations where making sound could increase danger',
  ];

  const KeyFeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How this works?', style: SizeConfig.sectionTitle),
        SizedBox(height: SizeConfig.defaultHeight2),
        Container(
          padding: EdgeInsets.all(SizeConfig.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.surface,

            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features
                .map((feature) => _buildFeatureItem(context, feature))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6.0,
      ), // spacing between items
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 6,
            ), // aligns bullet with first text line
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8), // spacing between bullet and text
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.text,
                height: 1.5, // line height for readability
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutVersionWidget extends StatelessWidget {
  const AboutVersionWidget({super.key});

  Future<String> getAppVersion() async {
    return '1.0.0';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About App', style: SizeConfig.sectionTitle),
        SizedBox(height: SizeConfig.defaultHeight2),
        Container(
          padding: EdgeInsets.all(SizeConfig.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: FutureBuilder<String>(
            future: getAppVersion(),
            builder: (context, snapshot) {
              return Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                    size: SizeConfig.screenWidth * 0.07,
                    semanticLabel: 'App Version',
                  ),
                  SizedBox(width: SizeConfig.paddingMedium),
                  Expanded(
                    child: Text(
                      snapshot.hasData
                          ? 'RescueMe v${snapshot.data}'
                          : 'RescueMe v1.0.0',
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.045,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget guestEcCard(BuildContext context) {
  return GestureDetector(
    onTap: () {
      isGuest = false;
      context.go('/');
    },
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.screenHPadding),
        child: Center(
          child: Text(
            'Login to add emergency contacts',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    ),
  );
}

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  File? _selectedImage;
  final nameController = TextEditingController();
  late String fullPhoneNumber;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        if (isGuest) {
          context.pop();
          Utilis.showSnackBar(
            'Login please to set profile picture',
            isErr: true,
          );
        }
      });
    }
  }

  defaultProfile() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Theme.of(context).colorScheme.surface,
              shape: const CircleBorder(),
              elevation: 6,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _pickImage,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: SizeConfig.blockWidth * 12,
                    backgroundColor: AppColors.background,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person_2_outlined,
                                size: 30,
                                color: AppColors.iconMuted,
                              ),
                              Text(
                                'Tap to upload',
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
            ),
            AuthTextField(
              label: 'Name',
              hint: 'Set Name to',
              icon: Icons.person_2_outlined,

              tFController: nameController,
              validator: (name) =>
                  name == null ? 'Enter valid name please' : null,
            ),

            SizedBox(height: SizeConfig.defaultHeight2),
            IntlPhoneField(
              showDropdownIcon: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.all(SizeConfig.paddingSmall),
                hint: Text('Required to send SOS'),
              ),
              initialCountryCode: 'IN', // default India
              onChanged: (phone) {
                fullPhoneNumber = phone.completeNumber;
              },
            ),

            SizedBox(height: SizeConfig.defaultHeight2),

            authButton(
              text: 'Done',
              onPressed: () async {
                if (isGuest) {
                  context.pop();
                  Utilis.showSnackBar(
                    'Login please to set profile picture',
                    isErr: true,
                  );
                } else {
                  if (nameController.text.isNotEmpty &&
                      _selectedImage != null) {
                    print('doing');
                    await CloudDB.updateNameAndDP(
                      _selectedImage,
                      nameController.text,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
