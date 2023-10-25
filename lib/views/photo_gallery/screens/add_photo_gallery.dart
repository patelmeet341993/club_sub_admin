import 'dart:typed_data';

import 'package:club_model/club_model.dart';
import 'package:club_sub_admin/backend/club_backend/club_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../backend/common/cloudinary_manager.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../backend/photo_gallery/photo_gallery_controller.dart';
import '../../../backend/photo_gallery/photo_gallery_provider.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_image_view_box.dart';
import '../../common/components/common_text_form_field.dart';
import '../../common/components/get_title.dart';
import '../../common/components/header_widget.dart';

class AddPhotoGalleryScreen extends StatefulWidget {
  static const String routeName = "/addphotogallery";
  final AddPhotoGalleryNavigationArguments arguments;

  const AddPhotoGalleryScreen({super.key, required this.arguments});

  @override
  State<AddPhotoGalleryScreen> createState() => _AddPhotoGalleryScreenState();
}

class _AddPhotoGalleryScreenState extends State<AddPhotoGalleryScreen> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late Future<void> futureGetData;
  late PhotoGalleryProvider photoGalleryProvider;
  late PhotoGalleryController photoGalleryController;
  TextEditingController sectionNameController = TextEditingController();
  GallerySection? pageGalleryModel;
  List<dynamic> clubGalleryImages = [];
  List<String> clubGalleryImagesToDeleteList = [];
  late ClubProvider clubProvider;
  final ImagePicker _picker = ImagePicker();

  Future<void> getData() async {
    if (widget.arguments.galleryModel != null) {
      pageGalleryModel = widget.arguments.galleryModel;
      sectionNameController.text = pageGalleryModel!.sectionName;
      clubGalleryImages.addAll(pageGalleryModel!.imageUrls);
    }
  }

  Future<void> chooseClubGalleryImagesMethod() async {
    List<XFile> xFiles = await _picker.pickMultiImage();

    if (xFiles.isNotEmpty) {
      for (var element in xFiles) {
        Uint8List xFile = await element.readAsBytes();
        clubGalleryImages.add(xFile);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> addGalleryImages() async {
    setState(() {
      isLoading = true;
    });
    String newId = MyUtils.getNewId(isFromUUuid: false);

    for (var element in clubGalleryImages) {
      if (element is Uint8List) {
        List<String> imageUrls = await CloudinaryManager().uploadImagesToCloudinary([element]);
        if (imageUrls.isNotEmpty) {
          clubGalleryImages.add(imageUrls.first);
        }
      }
    }

    for (var element in clubGalleryImagesToDeleteList) {
      await CloudinaryManager().deleteImagesFromCloudinary(images: [element]);
    }
    MyPrint.printOnConsole("Club Cover Images Length: ${clubGalleryImages.length}");

    List<String> methodGalleryImages = [];
    for (var element in clubGalleryImages) {
      if (element is String) {
        methodGalleryImages.add(element);
      }
    }

    String clubId = clubProvider.clubId.get();
    if(clubId.checkEmpty){
      MyToast.showError(context: context, msg: 'Issues in finding linked club with your profile');
      return;
    }

    if (widget.arguments.galleryModel != null && widget.arguments.index != null && widget.arguments.isEdit == true) {
      GallerySection gallerySection = GallerySection(
        id:widget.arguments.galleryModel!.id,
        createdTime:widget.arguments.galleryModel!.createdTime,
        imageUrls:methodGalleryImages,
        sectionName:sectionNameController.text.trim(),
      );

      await photoGalleryController.addPhotoGalleryFirebase(gallerySection,clubId);

    }else{
      GallerySection gallerySection = GallerySection(
        id:newId,
        createdTime: Timestamp.now(),
        imageUrls:methodGalleryImages,
        sectionName:sectionNameController.text.trim(),
      );

      await photoGalleryController.addPhotoGalleryFirebase(gallerySection,clubId);

    }

    setState(() {
      isLoading = false;
    });

    if (context.mounted && context.checkMounted()) {
      MyToast.showSuccess(context: context, msg: pageGalleryModel == null ? 'Photo Gallery Added Successfully' : 'Photo Gallery Edited Successfully');
    }

  }

  @override
  void initState() {
    super.initState();
    photoGalleryProvider = context.read<PhotoGalleryProvider>();
    clubProvider = context.read<ClubProvider>();
    photoGalleryController = PhotoGalleryController(photoGalleryProvider: photoGalleryProvider);
    futureGetData = getData();
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    MyPrint.printOnConsole("pageCourseModel?.id:${pageGalleryModel?.id}");

    return FutureBuilder(
      future: futureGetData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: Styles.bgColor,
            body: ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    HeaderWidget(title: pageGalleryModel == null ? "Add Photo Gallery" : "Edit Photo Gallery", isBackArrow: true),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getSectionName(),
                            const SizedBox(height: 20),
                            getImageListViewWidget(),
                            const SizedBox(height: 30),
                            submitButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const LoadingWidget();
        }
      },
    );
  }

  Widget getSectionName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Enter Section name*"),
              CommonTextFormField(
                controller: sectionNameController,
                hintText: "Enter Section name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter section name";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getImageListViewWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Upload Gallery Images"),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            clubGalleryImages.isNotEmpty
                ? Expanded(
                  child: SizedBox(
              height: 80,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                        children: List.generate(clubGalleryImages.length, (index) {
                          dynamic image = clubGalleryImages[index];
                          return CommonImageViewBox(
                            imageAsBytes: image is Uint8List ? image : null,
                            url: image is String ? image : null,
                            rightOnTap: () {
                              MyPrint.printOnConsole('Club List Length is " ${clubGalleryImages.length}');
                              MyPrint.printOnConsole("clubGalleryImages index:${clubGalleryImages.indexOf(image)}");
                              // int index = clubGalleryImages.indexOf(image);
                              // if (index > -1) clubGalleryImages.removeAt(index);
                              clubGalleryImages.removeAt(index);
                              if (image is String) {
                                clubGalleryImagesToDeleteList.add(image);
                              }
                              MyPrint.printOnConsole('Club List Length is " ${clubGalleryImages.length}');
                              setState(() {});
                            },
                          );
                        }),
                      ),
                  ),
                )
                : const SizedBox.shrink(),
            InkWell(
                onTap: () async {
                  await chooseClubGalleryImagesMethod();
                  MyPrint.printOnConsole('Club Cover Images Length: ${clubGalleryImages.length}');
                  MyPrint.printOnConsole('Club Cover Images Type: ${clubGalleryImages.first.runtimeType}');
                },
                child: const EmptyImageViewBox()),
          ],
        )
      ],
    );
  }

  Widget submitButton() {
    return CommonButton(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          await addGalleryImages();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
      text: pageGalleryModel == null ? '+   Add Photo Gallery ' : '+   Edit Photo Gallery',
      fontSize: 17,
    );
  }
}
