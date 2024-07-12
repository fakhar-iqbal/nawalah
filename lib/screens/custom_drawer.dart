import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/controllers/Restaurants/res_auth_controller.dart';
import 'package:provider/provider.dart';

import '../routes/routes_constants.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import 'Restaurant/Main/RAnalysisView.dart';
import 'Restaurant/RMenuView.dart';
import 'Restaurant/RProfileView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'logo_provider.dart';
import 'ngos_screen.dart';


class CustomDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const CustomDrawer({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late LogoProvider _logoProvider; // Instance of LogoProvider

  @override
  void initState() {
    super.initState();
    _logoProvider = Provider.of<LogoProvider>(context, listen: false);
    _fetchEmail();
  }

  Future<void> _fetchEmail() async {
    String? email = await SharedPreferencesHelper.getResEmail();
    if (email != null) {
      await _logoProvider.fetchLogo(email); // Fetch logo using provider
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shadowColor: Colors.white,
      elevation: 0.0,
      backgroundColor: Colors.white,
      shape: const BeveledRectangleBorder(),
      width: 200.w,
      child: Consumer<LogoProvider>(
        builder: (context, logoProvider, _) {
          if (logoProvider.logoUrl == null) {
            return Center(
              child: SizedBox(
                width: 40.w, // Adjust size as needed
                height: 40.w, // Adjust size as needed
                child: CircularProgressIndicator(
                  strokeWidth: 2.0, // Adjust thickness of the loader
                ),
              ),
            );
          } else {
            return ListView(
              children: [
                Wrap(
                  direction: Axis.vertical,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20.w, top: 15.h),
                      height: 80.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromRGBO(53, 53, 53, 1),
                          width: 2.w,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          logoProvider.logoUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const DrawerHeader(
                      child: Text(
                        'Donate &\nSave the world', // Placeholder text
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.black54),
                  title: Text(
                    AppLocalizations.of(context)!.profile,
                    style: const TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    widget.scaffoldKey.currentState?.closeDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RProfileView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book, color: Colors.black54),
                  title: Text(
                    AppLocalizations.of(context)!.menu,
                    style: const TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    widget.scaffoldKey.currentState?.closeDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RMenuView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined, color: Colors.black54),
                  title: const Text(
                    'Analytics',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    widget.scaffoldKey.currentState?.closeDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RAnalysisView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.black54),
                  title: Text(
                    AppLocalizations.of(context)!.signOut,
                    style: const TextStyle(color: Colors.black),
                  ),
                  onTap: () async {
                    await Provider.of<AuthController>(context, listen: false).logout();
                    if (mounted) {
                      context.pushReplacement(AppRouteConstants.getStartedRoute);
                    }
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}