import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/wallet_page.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/size_config.dart';

// Reusable SectionHeader widget
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onActionPressed;
  final String? tooltip;
  final IconData? actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.onActionPressed,
    this.tooltip,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (onActionPressed != null && actionIcon != null)
          IconButton(
            onPressed: onActionPressed,
            icon: Icon(actionIcon, semanticLabel: tooltip),
            tooltip: tooltip,
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
  // Sample dynamic data for emergency contacts
  List<Map<String, String>> emergencyContacts = [
    {'name': 'John Doe', 'phone': '+1234567890'},
    {'name': 'Jane Smith', 'phone': '+0987654321'},
  ];

  void addContact(String name, String phone) {
    setState(() {
      emergencyContacts.add({'name': name, 'phone': phone});
    });
  }

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
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(SizeConfig.paddingSmall),
                      child: CircleAvatar(
                        radius: SizeConfig.screenWidth * 0.15,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.person_outlined,
                            size: SizeConfig.iconLarge,
                            semanticLabel: 'Profile Picture',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.background,
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Navigate to edit profile picture screen
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            semanticLabel: 'Edit Profile Picture',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // Profile Name
                Text(
                  'User Name', // Replace with dynamic user data
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Guest User',
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // Emergency Contacts
                SectionHeader(
                  title: 'Emergency Contacts',
                  onActionPressed: () {
                    // Navigate to add contact screen
                    addContact('New Contact', '+0000000000'); // Example action
                  },
                  actionIcon: Icons.add_circle_outline,
                  tooltip: 'Add Contact',
                ),
                Card(
                  child: emergencyContacts.isEmpty
                      ? Center(
                          child: Text(
                            'No contacts added',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: emergencyContacts.length,
                          itemBuilder: (context, index) {
                            final contact = emergencyContacts[index];
                            return ListTile(
                              leading: Icon(Icons.phone_outlined),
                              title: Text(contact['name'] ?? 'Unknown'),
                              subtitle: Text(
                                contact['phone'] ?? 'No phone number',
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: () {
                                  setState(() {
                                    emergencyContacts.removeAt(index);
                                  });
                                },
                                tooltip: 'Delete Contact',
                              ),
                            );
                          },
                        ),
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // Permissions
                SectionHeader(
                  title: 'Permissions',
                  onActionPressed: () {
                    // Navigate to edit permissions screen
                  },
                  actionIcon: Icons.edit_outlined,
                  tooltip: 'Edit Permissions',
                ),
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(SizeConfig.paddingSmall),
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
                        padding: EdgeInsets.all(SizeConfig.paddingSmall),
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

                // Edit Profile Button
                AppButton(
                  text: 'Edit Profile',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icons.edit,
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.03),

                // Sign Out Button
                Container(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async{
                      if (isGuest) {
                        isGuest = false;
                        context.goNamed('auth');
                      }
                      await auth.signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
            color: AppColors.iconSecondary,
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
        Text('Key Features', style: SizeConfig.sectionTitle),
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
