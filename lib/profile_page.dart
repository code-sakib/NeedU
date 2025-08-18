import 'package:flutter/material.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/size_config.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: SizeConfig.screenHeight * 0.08, //8% of screen height
              horizontal: SizeConfig.screenWidth * 0.05, //5% of screen width
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  children: [
                    // Circle avatar for profile picture
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CircleAvatar(
                        radius: SizeConfig.screenWidth * 0.15,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.person_outlined,
                            size: SizeConfig.iconLarge,
                          ),
                        ), // Replace with your image
                      ),
                    ),
                    // Profile edit icon
                    Positioned(
                      bottom: 0,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.background,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.edit_outlined),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Profile name
                Text(
                  'User Name',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Guest User',
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                //Emergency contacts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      "Emergency Contacts",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        // Add your button action here
                      },
                      icon: Icon(Icons.add_circle_outline),
                      tooltip: 'Add Contact',
                    ),
                  ],
                ),

                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.phone,
                      size: SizeConfig.blockHeight * 3,
                    ),
                    title: Text('John Doe'),
                    subtitle: Text('+1234567890'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Add your edit action here
                      },
                    ),
                  ),
                ),

                //Permissions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Permissions",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        // Add your button action here
                      },
                      icon: Icon(Icons.edit_outlined),
                      tooltip: 'Edit Permissions',
                    ),
                  ],
                ),
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.mic_outlined),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
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
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.location_on_outlined),
                            Wrap(
                              direction: Axis.vertical,
                              clipBehavior: Clip.antiAlias,
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

                //
                const PricingWalletWidget(),

                //
                const KeyFeaturesWidget(),

                //
                const AboutVersionWidget(),

                ElevatedButton(
                  onPressed: () {
                    // Add your button action here
                    Navigator.of(context).pop();
                  },
                  child: Text('Edit Profile'),
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
        Text(
          "Pricing & Wallet",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        // Pricing Table
        _buildPricingTable(),
        SizedBox(height: 24),
        // Manage Wallet Button
        _buildManageWalletButton(),
      ],
    );
  }

  Widget _buildPricingTable() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Header Row
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

          // Starter Plan Row
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                _buildDataCell('Starter Plan'),
                _buildDataCell('3 Emergency\nServices'),
                _buildDataCell('\$0'),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: AppColors.border,
            margin: EdgeInsets.symmetric(horizontal: 16),
          ),

          // Pro Plan Row
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                _buildDataCell('Pro Plan'),
                _buildDataCell('Per Service\nCalled'),
                _buildDataCell('\$1'),
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
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.iconSecondary, // Black text on green background
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.text,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildManageWalletButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
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
            // Handle manage wallet tap
            print('Manage Wallet tapped');
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Manage Wallet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.primary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    return _buildKeyFeaturesSection();
  }

  Widget _buildKeyFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 20),
          child: Text(
            'Key Features',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
        
        // Features Card
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features.map((feature) => _buildFeatureItem(feature)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green bullet point
          Container(
            margin: EdgeInsets.only(top: 8, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          
          // Feature text
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.text,
                height: 1.5,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 20),
          child: Text(
            'About App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
        
        // About Card
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Shield Icon
              Container(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              
              // App Version Text
              Expanded(
                child: Text(
                  'RescueMe v1.0.0',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

