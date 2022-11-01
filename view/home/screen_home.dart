import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go4sheq/bloc/bloc.dart';
import 'package:go4sheq/util/app_util.dart';
import 'package:go4sheq/view/checklist/tab_checklist.dart';
import 'package:go4sheq/view/component/alert_dialog_alert.dart';
import 'package:go4sheq/view/component/container_screen_background_home.dart';
import 'package:go4sheq/view/dashboard/tab_dashboard.dart';
import 'package:go4sheq/view/home/icon_navigation_bar.dart';
import 'package:go4sheq/view/login/screen_login.dart';
import 'package:go4sheq/view/notification/screen_notification.dart';
import 'package:go4sheq/view/profile/screen_my_profile.dart';
import 'package:go4sheq/view/settings/screen_settings.dart';
import 'package:go4sheq/view/task/tab_task.dart';

class ScreenHome extends StatefulWidget {
  static const String id = 'screen_home';

  const ScreenHome({Key? key}) : super(key: key);

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  int _selectedIndex = 0; // Total Tab: 3 (Dashboard, Task, Checklist)

  late List<Widget> _pages;

  final PageController _pageController = PageController(initialPage: 0);

  void _onPageChanged(int index) {
    _selectedIndex = index;
    setState(() {});
  }

  void _onItemTapped(int selectedIndex) {
    _pageController.jumpToPage(selectedIndex);
  }

  _popupMenuItemClicked(int index) async {
    switch (index) {
      case 0: // My Profile
        Navigator.pushNamed(context, ScreenMyProfile.id);
        break;
      case 1: // Settings
        Navigator.pushNamed(context, ScreenSettings.id);
        break;
      case 2: // Logout
        _showAlertDialog(
          title: AppLocalizations.of(context)!.logout,
          content: AppLocalizations.of(context)!.areYouSureWantToLogout,
          btnOk: AppLocalizations.of(context)!.yes,
          onClickedOk: () async {
            Navigator.pop(context);
            await context.read<AppBloc>().userLogout();
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, ScreenLogin.id, (route) => false);
          },
          btnCancel: AppLocalizations.of(context)!.no,
          onClickedCancel: () => Navigator.pop(context),
        );
        break;
    }
  }

  void _handleMessage(RemoteMessage message) {
    Navigator.pushNamed(context, ScreenNotification.id);
  }

  _showAlertDialog({bool barrierDismissible = true, String? title, String? content, String btnOk = 'Ok', String btnCancel = 'Cancel', VoidCallback? onClickedOk, VoidCallback? onClickedCancel}) {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialogAlert(
          title: title,
          content: content,
          btnOk: btnOk,
          onClickedOk: onClickedOk ??
              () {
                Navigator.pop(context);
              },
          btnCancel: btnCancel,
          onClickedCancel: onClickedCancel,
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex == 0) {
      return true;
    } else {
      _onItemTapped(0);
      return false;
    }
  }

  _init() async {
    _pages = [
      TabDashboard(
        onClickTask: () => _onItemTapped(1),
        onClickChecklist: () => _onItemTapped(2),
      ),
      const TabTask(),
      const TabChecklist(),
    ];

    // Get any messages which caused the application to open from a terminated state.
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleMessage(initialMessage);
  }

  @override
  initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
          children: [
            ContainerScreenBackgroundHome(
              onClickedLogo: () => _onWillPop(),
              onPopupMenuItemSelected: _popupMenuItemClicked,
              onClickedNotification: () {
                AppUtil.hideKeyboard(context);
                Navigator.pushNamed(context, ScreenNotification.id);
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 100),
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
          boxShadow: [BoxShadow(color: Color(0x80CCCCCC), spreadRadius: 0, blurRadius: 5)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          child: BottomNavigationBar(
            onTap: _onItemTapped,
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedFontSize: 0.0,
            unselectedFontSize: 0.0,
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: const IconNavigationBar(image: 'icon_nav_dashboard.png'),
                activeIcon: const IconNavigationBar(image: 'icon_nav_dashboard.png', isActive: true),
                label: '',
                tooltip: AppLocalizations.of(context)!.dashboard,
              ),
              BottomNavigationBarItem(
                icon: const IconNavigationBar(image: 'icon_nav_checklist.png'),
                activeIcon: const IconNavigationBar(image: 'icon_nav_checklist.png', isActive: true),
                label: '',
                tooltip: AppLocalizations.of(context)!.tasks,
              ),
              BottomNavigationBarItem(
                icon: const IconNavigationBar(image: 'icon_nav_task.png'),
                activeIcon: const IconNavigationBar(image: 'icon_nav_task.png', isActive: true),
                label: '',
                tooltip: AppLocalizations.of(context)!.checklist,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
