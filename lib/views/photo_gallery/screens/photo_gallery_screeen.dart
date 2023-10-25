import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/club_backend/club_provider.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/photo_gallery/photo_gallery_controller.dart';
import '../../../backend/photo_gallery/photo_gallery_provider.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/header_widget.dart';
import 'package:club_model/backend/navigation/navigation_operation_parameters.dart';
import 'package:club_model/backend/navigation/navigation_type.dart';
import 'package:club_model/club_model.dart';
import 'package:club_model/view/common/components/common_text.dart';


class PhotoGalleryScreenNavigator extends StatefulWidget {
  const   PhotoGalleryScreenNavigator({Key? key}) : super(key: key);

  @override
  _PhotoGalleryScreenNavigatorState createState() => _PhotoGalleryScreenNavigatorState();
}

class _PhotoGalleryScreenNavigatorState extends State<PhotoGalleryScreenNavigator>  {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.photoGalleryScreenNavigator,
      onGenerateRoute: NavigationController.onPhotoGalleryGeneratedRoutes,
    );
  }
}

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  late Future<void> futureGetData;

  late PhotoGalleryProvider photoGalleryProvider;
  late PhotoGalleryController photoGalleryController;

  late ClubProvider clubProvider;

  Future<void> getData() async {
    String clubId = clubProvider.clubId.get();

    if(clubId.checkEmpty){
      MyToast.showError(context: context, msg: 'Issues in finding linked club with your profile');
      return;
    }

    await photoGalleryController.getGallerySectionList(clubId);

  }

  @override
  void initState() {
    super.initState();
    photoGalleryProvider = context.read<PhotoGalleryProvider>();
    clubProvider = context.read<ClubProvider>();
    photoGalleryController = PhotoGalleryController(photoGalleryProvider: photoGalleryProvider);
    futureGetData =  getData();
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();
    return  FutureBuilder<void>(
        future: futureGetData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: LoadingWidget());
          }
          return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Column(
          children: [
            HeaderWidget(
              title: "Photo Gallery",
              suffixWidget: CommonButton(
                text: "Add Photo Gallery",
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onTap: () async {
                  await NavigationController.navigateToAddPhotoGalleryScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        navigationType: NavigationType.pushNamed,
                        context: context,
                      ),
                      addPhotoGalleryScreenNavigationArguments: AddPhotoGalleryNavigationArguments());
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: getPhotoGalleryList()),
          ],
        ),
      ),
    );
        });
  }

  Widget getPhotoGalleryList() {
    return Consumer(builder:
        (BuildContext context, PhotoGalleryProvider photoGalleryProvider, Widget? child) {
      if (photoGalleryProvider.photoGalleryModelList.getList().isEmpty) {
        return Center(
          child: CommonText(
            text: "No Photo Galleries Available",
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        );
      }

      //List<NewsFeedModel> newsList = newsProvider.newsList;
      return ListView.builder(
        itemCount: photoGalleryProvider.photoGalleryModelList.getList().length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return singlePhotoGallery(photoGalleryProvider.photoGalleryModelList.getList()[index], index);
        },
      );
    });
  }

  Widget singlePhotoGallery(GallerySection photoGallerySection, int index) {
    List<String> imageUrls = [];
    int i=0;
    for (var element in photoGallerySection.imageUrls) {
      i++;
      if(i<10){
        imageUrls.add(element);
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CommonPopup(
                    text: "Want to Edit Photo Gallery?",
                    rightText: "Yes",
                    rightOnTap: () async {
                      Navigator.pop(context);
                      await NavigationController.navigateToAddPhotoGalleryScreen(
                        navigationOperationParameters: NavigationOperationParameters(
                          navigationType: NavigationType.pushNamed,
                          context: NavigationController.photoGalleryScreenNavigator.currentContext!,
                        ),
                        addPhotoGalleryScreenNavigationArguments: AddPhotoGalleryNavigationArguments(
                          galleryModel: photoGallerySection,
                          index: index,
                          isEdit: true,
                        ),
                      );
                      mySetState();
                    },
                  );
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Styles.yellow, width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: photoGallerySection.sectionName,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 10),
                          CommonText(
                            text: photoGallerySection.createdTime == null ? 'Created Date: No Data' : 'Created Date: ${DateFormat("dd-MMM-yyyy").format(photoGallerySection.createdTime!.toDate())}',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            textOverFlow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        alignment: WrapAlignment.end,
                        children: imageUrls.map((e) {
                          return CommonCachedNetworkImage(imageUrl: e, height: 50,width: 50, borderRadius: 10,);
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 5,),
        InkWell(
            onTap: (){
              showDialog(
                context: context,
                builder: (context) {
                  return CommonPopup(
                    text: "Want to Delete Photo Gallery?",
                    rightText: "Yes",
                    rightOnTap: () async {
                      Navigator.pop(context);
                      String clubId = clubProvider.clubId.get();

                      if(clubId.checkEmpty){
                        MyToast.showError(context: context, msg: 'Issues in finding linked club with your profile');
                        return;
                      }
                      await  photoGalleryController.removePhotoGalleryFirebase(photoGallerySection,clubId);
                      MyToast.showError(context: context, msg: 'Club Deleted Successfully');

                    },
                  );
                },
              );
            },
            child: Icon(Icons.delete,color: Colors.red,size: 25,)),
        SizedBox(width: 5,),
      ],
    );
  }
}
