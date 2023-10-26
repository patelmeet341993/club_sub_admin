import 'package:club_model/club_model.dart';
import 'package:club_model/view/common/components/common_text.dart';
import 'package:club_sub_admin/backend/club_products/club_products_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../backend/club_backend/club_provider.dart';
import '../../../backend/club_products/club_products_provider.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../configs/constants.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/header_widget.dart';

class ClubProductsListScreenNavigator extends StatefulWidget {
  const ClubProductsListScreenNavigator({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ClubProductsListScreenNavigatorState createState() => _ClubProductsListScreenNavigatorState();
}

class _ClubProductsListScreenNavigatorState extends State<ClubProductsListScreenNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.clubProductsScreenNavigator,
      onGenerateRoute: NavigationController.onClubProductsRoutes,
    );
  }
}

class ClubProductsListScreen extends StatefulWidget {
  const ClubProductsListScreen({Key? key}) : super(key: key);

  @override
  State<ClubProductsListScreen> createState() => _ClubProductsListScreenState();
}

class _ClubProductsListScreenState extends State<ClubProductsListScreen> with MySafeState {
  late ClubProvider clubProvider;
  late ClubProductsProvider clubProductsProvider;
  late ClubProductsController clubProductsController;
  ClubModel? pageClubModel;
  late Future<void> futureGetData;
  bool isLoading = false;

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    pageClubModel = clubProvider.loggedInClubModel.get();
    if (pageClubModel == null) {
      return;
    }
    await clubProductsController.getProductsList(productIds: pageClubModel!.clubProductIdList, isNotify: false);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteClub(ClubModel clubModel, int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return CommonPopup(
          text: "Want to Delete this club?",
          rightText: "Yes",
          rightOnTap: () async {
            await clubProductsController.deleteClubFromFirebase(clubModel);
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
            setState(() {});
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    clubProvider = context.read<ClubProvider>();
    clubProductsProvider = Provider.of<ClubProductsProvider>(context, listen: false);
    clubProductsController = ClubProductsController(clubProductsProvider: clubProductsProvider);
    futureGetData = getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureGetData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (pageClubModel == null) {
              return Center(
                child: CommonText(
                  text: "No Club Data Available",
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              );
            }

            return Scaffold(
              backgroundColor: Styles.bgColor,
              body: ModalProgressHUD(
                inAsyncCall: isLoading,
                child: Column(
                  children: [
                    HeaderWidget(
                      title: "Club Products",
                      suffixWidget: Row(
                        children: [
                          CommonButton(
                              text: "Exclusive Product",
                              icon: Icon(
                                Icons.add,
                                color: Styles.white,
                              ),
                              onTap: () {
                                BuildContext? context = NavigationController.clubProductsScreenNavigator.currentContext;
                                if(context == null) return;
                                NavigationController.navigateToAddClubExclusiveProducts(
                                  navigationOperationParameters: NavigationOperationParameters(
                                    navigationType: NavigationType.pushNamed,
                                    context: context,
                                  ),
                                );
                              }),
                          SizedBox(
                            width: 15,
                          ),
                          CommonButton(
                              text: "Product",
                              icon: Icon(
                                Icons.add,
                                color: Styles.white,
                              ),
                              onTap: () {
                                BuildContext? context = NavigationController.clubProductsScreenNavigator.currentContext;
                                if(context == null) return;
                                NavigationController.navigateToAddClubProducts(
                                  navigationOperationParameters: NavigationOperationParameters(
                                    navigationType: NavigationType.pushNamed,
                                    context: context,
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(child: getClubProductsList()),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: LoadingWidget());
          }
        });
  }

  Widget getClubProductsList() {
    return Consumer(builder: (BuildContext context, ClubProductsProvider clubProductsProvider, Widget? child) {
      if (clubProductsProvider.clubProductList.length < 1) {
        return Center(
          child: CommonText(
            text: "No Club Products Available",
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        );
      }

      return ListView.builder(
        itemCount: clubProductsProvider.clubProductList.length + 1,
        itemBuilder: (context, index) {
          if ((index == 0 && clubProductsProvider.clubProductList.length == 0) || (index == clubProductsProvider.clubProductList.length)) {
            if (clubProductsProvider.clubProductLoading.get()) {
              return Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Styles.bgColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(child: CircularProgressIndicator(color: Styles.bgSideMenu)),
              );
            } else {
              return const SizedBox();
            }
          }

          if (clubProductsProvider.hasMoreClubProduct.get() &&
              index > (clubProductsProvider.clubProductList.length - MyAppConstants.clubProductRefreshIndexForPagination)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              clubProductsController.getProductsList(productIds: pageClubModel!.clubProductIdList, isRefresh: false, isNotify: false);
            });
          }

          return singleProduct(clubProductsProvider.clubProductList.getList()[index], index);
        },
      );
    });
  }

  Widget singleProduct(ProductModel productModel, index) {
    MyPrint.printOnConsole("productModel.thumbnailImageUrl: ${productModel.thumbnailImageUrl}");
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Styles.white,
          border: Border.all(color: Styles.yellow, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Styles.bgSideMenu.withOpacity(.6)),
                ),
                child: CommonCachedNetworkImage(
                  imageUrl: productModel.thumbnailImageUrl,
                  height: 80,
                  width: 80,
                  borderRadius: 4,
                )),
            const SizedBox(
              width: 30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: productModel.name,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 5),
                (productModel.brand?.name.isNotEmpty ?? false)
                    ? CommonText(
                        text: 'by ${productModel.brand!.name}',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 3),
                CommonText(
                  text: productModel.createdTime == null
                      ? 'Created Date: No Data'
                      : 'Created Date: ${DateFormat("dd-MMM-yyyy").format(productModel.createdTime!.toDate())}',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  fontSize: 14,
                  textOverFlow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            const Spacer(),
            Column(
              children: [
                CommonText(
                  text: 'Price :  ${productModel.price} ₹',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 3),
                CommonText(
                  text: 'Size(ml) :  ${productModel.sizeInML} ml',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget getEnableSwitch({
    required bool value,
    void Function(bool?)? onChanged,
  }) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: Styles.bgSideMenu,
    );
  }
}
