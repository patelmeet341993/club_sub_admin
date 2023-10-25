
import 'package:club_model/club_model.dart';
import 'package:club_sub_admin/views/photo_gallery/screens/photo_gallery_screeen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/authentication_provider.dart';
import '../../../backend/club_backend/club_provider.dart';
import '../../../backend/common/menu_provider.dart';
import '../../club_products/screens/club_products.dart';
import '../../club_profile/screen/club_profile_screen.dart';
import '../../common/components/app_response.dart';
import '../../common/components/side_bar.dart';
import '../../system/screen/system_main_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tabNumber = 0;

  @override
  void initState() {
    super.initState();
    MyPrint.printOnConsole('On Main Home Page');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticationProvider, ClubProvider>(
      builder: (BuildContext context, AuthenticationProvider adminProvider, ClubProvider clubProvider,_) {
        return Scaffold(
          drawer: SideBar(
            drawerListTile: [
              DrawerListTile(
                title: "Club Profile",
                icon: Icons.account_box_outlined,
                press: () {
                  setState(() {
                    tabNumber = 0;
                  });
                },
              ),
              DrawerListTile(
                title: "Club Images Gallery",
                icon: Icons.account_box_outlined,
                press: () {
                  setState(() {
                    tabNumber = 1;
                  });
                },
              ),
              DrawerListTile(
                title: "Club Products",
                icon: Icons.account_box_outlined,
                press: () {
                  setState(() {
                    tabNumber = 2;
                  });
                },
              ),
              DrawerListTile(
                title: "System",
                icon: Icons.branding_watermark,
                press: () {
                  setState(() {
                    tabNumber = 3;
                  });
                },
              ),
            ],
          ),
          key: Provider.of<MenuProvider>(context, listen: false).scaffoldKey,
          backgroundColor: Styles.bgSideMenu,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (AppResponsive.isDesktop(context))
                  Expanded(
                    child: SideBar(
                      clubName: clubProvider.loggedInClubModel.get()?.name ?? "No Club Linked",
                      drawerListTile: [
                        DrawerListTile(
                          title: "Club Profile",
                          icon: Icons.account_box_outlined,
                          press: () {
                            setState(() {
                              tabNumber = 0;
                            });
                          },
                        ),
                        DrawerListTile(
                          title: "Club Images Gallery",
                          icon: Icons.image_outlined,
                          press: () {
                            setState(() {
                              tabNumber = 1;
                            });
                          },
                        ),
                        DrawerListTile(
                          title: "Club Products",
                          icon: Icons.account_box_outlined,
                          press: () {
                            setState(() {
                              tabNumber = 2;
                            });
                          },
                        ),
                        DrawerListTile(
                          title: "System",
                          icon: Icons.branding_watermark,
                          press: () {
                            setState(() {
                              tabNumber = 3;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                /// Main Body Part
                Expanded(
                  flex: 4,
                  child: Container(
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Styles.bgColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: getPageWidget(tabNumber)),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget getPageWidget(int number) {
    switch (number) {
      case 0:
        {
          return const ClubProfileScreen();
        }
      case 1:
        {
          return const PhotoGalleryScreenNavigator();
        }
      case 2:
        {
          return const ClubProductsListScreenNavigator();
        }
      case 3:
        {
          return const SystemScreenNavigator();
        }
      // case 3:
      //   {
      //     return const UserScreenNavigator();
      //   }
      // case 4:
      //   {
      //     return const SystemScreenNavigator();
      //   }
      //   case 5:
      //   {
      //     return const NotificationListScreenNavigator();
      //   }
      //   case 6:
      //   {
      //     return const ClubProfileScreenNavigator();
      //   }
      //   case 7:
      //   {
      //     return const ClubUserScreenNavigator();
      //   }
      default:
        {
          return const ClubProfileScreen();
        }
    }
  }
}
