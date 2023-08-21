import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CMAppBar extends StatelessWidget {
  CMAppBar({
    this.title,
    this.doneButton,
    this.notificationsFilterButton,
  });

  final String? title;
  final bool? doneButton;
  final bool? notificationsFilterButton;

  @override
  Widget build(BuildContext context) {
    if (doneButton == true) {
      return PreferredSize(
          preferredSize: Size.fromHeight(42),
          child: AppBar(
              backgroundColor: ColorPrimary,
              primary: true,
              centerTitle: true,
              title: title == null
                  ? Image.asset(
                      'assets/images/UCSanDiegoLogo-nav.png',
                      fit: BoxFit.contain,
                      height: 28,
                    )
                  : Text(title!),
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: darkButtonColor,
                      ),
                      child: Text(
                        'Done',
                      ),
                      onPressed: () {
                        // Set tab bar index to the Home tab
                        Provider.of<BottomNavigationBarProvider>(context,
                                listen: false)
                            .currentIndex = NavigatorConstants.HomeTab;

                        // Navigate to Home tab
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            RoutePaths.BottomNavigationBar,
                            (Route<dynamic> route) => false);

                        // change the appBar title to the ucsd logo
                        Provider.of<CustomAppBar>(context, listen: false)
                            .changeTitle(CustomAppBar().appBar.title);
                      },
                    ))
              ],
              systemOverlayStyle: SystemUiOverlayStyle.light));
    } else if (notificationsFilterButton == true) {
      return PreferredSize(
          preferredSize: Size.fromHeight(42),
          child: AppBar(
              backgroundColor: ColorPrimary,
              primary: true,
              centerTitle: true,
              title: title == null
                  ? Image.asset(
                      'assets/images/UCSanDiegoLogo-nav.png',
                      fit: BoxFit.contain,
                      height: 28,
                    )
                  : Text(title!),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.filter_list_outlined),
                  onPressed: () {
                    Navigator.pushNamed(
                        context, RoutePaths.NotificationsFilter);
                  },
                )
              ],
              systemOverlayStyle: SystemUiOverlayStyle.light));
    } else {
      return PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
          backgroundColor: ColorPrimary,
          primary: true,
          centerTitle: true,
          title: title == null
              ? Image.asset(
                  'assets/images/UCSanDiegoLogo-nav.png',
                  fit: BoxFit.contain,
                  height: 28,
                )
              : Text(title!),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      );
    }
  }
}

class CustomAppBar extends ChangeNotifier {
  late CMAppBar appBar;
  String? title;
  bool? doneButton;
  bool? notificationsFilterButton;

  CustomAppBar() {
    makeAppBar();
  }

  makeAppBar() {
    appBar = CMAppBar(
      title: title,
      doneButton: doneButton,
      notificationsFilterButton: notificationsFilterButton,
    );
  }

  changeTitle(String? newTitle, {done: false, notification: false}) {
    title = RouteTitles.titleMap[newTitle];
    doneButton = done;
    notificationsFilterButton = notification;

    // if (newTitle == "Notifications") {
    //   notificationsFilterButton = true;
    // } else {
    //   notificationsFilterButton = false;
    // }

    makeAppBar();
  }
}
