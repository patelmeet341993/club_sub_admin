import 'dart:typed_data';

import 'package:club_sub_admin/backend/club_backend/club_provider.dart';
import 'package:club_sub_admin/models/edit_club_request_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:club_model/club_model.dart';
import 'package:club_model/view/common/components/common_text.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../backend/club_backend/club_controller.dart';
import '../../../backend/common/cloudinary_manager.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_image_view_box.dart';
import '../../common/components/common_text_form_field.dart';
import '../../common/components/header_widget.dart';


class ClubProfileScreen extends StatefulWidget {
  const ClubProfileScreen({Key? key}) : super(key: key);

  @override
  State<ClubProfileScreen> createState() => _ClubProfileScreenState();
}

class _ClubProfileScreenState extends State<ClubProfileScreen> {

  final _formKey = GlobalKey<FormState>();
  late Future<bool> futureGetData;
  bool isLoading = false;
  ClubModel? clubModel;
  late ClubController clubController;
  late ClubProvider clubProvider;

  TextEditingController clubNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController clubAddressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  String? thumbnailImageUrl;
  Uint8List? thumbnailImage;
  List<dynamic> clubCoverImages = [];
  List<String> coverImagesToDeleteList = [];

  bool isClubEnabled = true;
  bool isAdminEnabled = true;

  Future<void> addThumbnailImage() async {
    setState(() {});
    XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      thumbnailImage = await file.readAsBytes();
      MyPrint.printOnConsole("Mime type: ${file.mimeType}");
    }
    if (mounted) setState(() {});
  }

  Future<void> chooseClubCoverImagesMethod() async {
    XFile? xFileAbove = await _picker.pickImage(source: ImageSource.gallery);

    if (xFileAbove != null) {
      Uint8List xFile = await xFileAbove.readAsBytes();
      clubCoverImages.add(xFile);
    }
    if (mounted) setState(() {});
  }

  Future<void> chooseClubGalleryImagesMethod(List<dynamic> list) async {
    List<XFile> xFiles = await _picker.pickMultiImage();

    if (xFiles.isNotEmpty) {
      for (var element in xFiles) {
        Uint8List xFile = await element.readAsBytes();
        list.add(xFile);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> addClub() async {
    setState(() {
      isLoading = true;
    });
    String newId = MyUtils.getNewId(isFromUUuid: false);
    String cloudinaryThumbnailImageUrl = '';

    if (thumbnailImage != null) {
      List<String> uploadedImages = [];
      uploadedImages = await CloudinaryManager().uploadImagesToCloudinary([thumbnailImage!]);
      if (uploadedImages.isNotEmpty) {
        cloudinaryThumbnailImageUrl = uploadedImages.first;
      }
    }

    for (var element in clubCoverImages) {
      if(element is Uint8List){
        List<String> imageUrls = await  CloudinaryManager().uploadImagesToCloudinary([element]);
        if (imageUrls.isNotEmpty) {
          clubCoverImages.add(imageUrls.first);
        }
      }
    }
    for (var element in coverImagesToDeleteList) {
      await  CloudinaryManager().deleteImagesFromCloudinary(images: [element]);
    }
    MyPrint.printOnConsole("Club Cover Images Length: ${clubCoverImages.length}");

    List<String> methodCoverImages = [];
    for(var element in clubCoverImages){
      if(element is String){
        methodCoverImages.add(element);
      }
    }


    EditClubRequestModel editClubRequestModel = EditClubRequestModel(

    );

    await clubController.updateClubModelToFirebase(editClubRequestModel);

  }

  Future<bool> getData() async {

    ClubModel? clubModel = clubProvider.loggedInClubModel.get();

    if(clubModel == null && clubProvider.clubId.get().isNotEmpty){
      clubModel = await clubController.getClubFromId(clubProvider.clubId.get());
    }

    if(clubModel == null){
      return false;
    }

    clubNameController.text = clubModel.name;
    mobileNumberController.text = clubModel.mobileNumber;
    clubAddressController.text = clubModel.address;
    thumbnailImageUrl = clubModel.thumbnailImageUrl;
    clubCoverImages.addAll(clubModel.coverImages);


    return true;


  }

  @override
  void initState() {
    super.initState();
    clubProvider = context.read<ClubProvider>();
    clubController = ClubController(clubProvider: clubProvider);
    futureGetData =  getData();
  }

  @override
  Widget build(BuildContext context)  {
    return FutureBuilder<bool>(
        future: futureGetData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: LoadingWidget());
          }

          if (snapshot.data != true) {
            return  Center(child: CommonText(text: 'No Club Data Available',fontSize: 25,fontWeight: FontWeight.w600,));
          }

          return Scaffold(
            backgroundColor: Styles.bgColor,
            body: ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Column(
                children: [
                  HeaderWidget(
                    title: "Edit Club Profile",
                  ),
                  getMainWidget(),
                ],
              ),
            ),
          );
        });
  }

  Widget getMainWidget(){
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            CommonText(text: " Club Basic Information", fontWeight: FontWeight.bold, fontSize: 25, color: Styles.bgSideMenu.withOpacity(.6)),
            const SizedBox(
              height: 20,
            ),
            getNameAndMobileNumber(),
            const SizedBox(
              height: 30,
            ),
            getAddressTextField(),
            const SizedBox(
              height: 30,
            ),
            CommonText(text: " Images", fontWeight: FontWeight.bold, fontSize: 25, color: Styles.bgSideMenu.withOpacity(.6)),
            const SizedBox(
              height: 10,
            ),
            getAddThumbnailImage(),
            const SizedBox(
              height: 30,
            ),
            getClubCoverImages(),
            const SizedBox(
              height: 40,
            ),
            getGalleryImages(),
            const SizedBox(
              height: 40,
            ),
            getAddClubButton(),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }


  Widget getNameAndMobileNumber() {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTitle(title: "Enter Club Name*"),
              CommonTextFormField(
                controller: clubNameController,
                hintText: "Enter Club Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter a Club Name";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTitle(title: "Enter Mobile Number*"),
              CommonTextFormField(
                controller: mobileNumberController,
                hintText: "Enter Mobile Number",
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Mobile Number Cannot be empty";
                  } else {
                    if (RegExp(r"^\d{10}").hasMatch(val)) {
                      return null;
                    } else {
                      return "Invalid Mobile Number";
                    }
                  }
                },
                keyboardType: TextInputType.number,
                textInputFormatter: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getAddressTextField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(title: "Enter Address Of Club"),
        CommonTextFormField(
          controller: clubAddressController,
          hintText: "Enter Address of Club",
          minLines: 2,
          maxLines: 10,
          validator: (value) {
            return null;
          },
        ),
      ],
    );
  }

  Widget getTitle({required String title}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: CommonText(
        text: " $title",
        fontWeight: FontWeight.bold,
        fontSize: 16,
        textAlign: TextAlign.start,
        color: Styles.bgSideMenu,
      ),
    );
  }

  Widget getAddThumbnailImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(title: "Choose Club Thumbnail Image*"),
        thumbnailImage == null && thumbnailImageUrl == null && (thumbnailImageUrl?.isEmpty ?? true)
            ? InkWell(
            onTap: () async {
              await addThumbnailImage();
            },
            child: const EmptyImageViewBox())
            : CommonImageViewBox(
          imageAsBytes: thumbnailImage,
          url: thumbnailImageUrl,
          rightOnTap: () {
            thumbnailImage = null;
            thumbnailImageUrl = null;
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget getClubCoverImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(title: "Upload Club Cover Images(up to 10 images)"),
        Row(
          children: [
            clubCoverImages.isNotEmpty
                ? Flexible(
              child: Container(
                padding: EdgeInsets.zero,
                height: 80,
                child: ListView.builder(
                    itemCount: clubCoverImages.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic image = clubCoverImages[index];
                      MyPrint.printOnConsole("image type : ${image.runtimeType.toString()}");
                      return CommonImageViewBox(
                        imageAsBytes: image is Uint8List ? image : null,
                        url: image is String ? image : null,
                        rightOnTap: () {
                          clubCoverImages.removeAt(index);
                          if(image is String){
                            coverImagesToDeleteList.add(image);
                          }
                          MyPrint.printOnConsole('Club List Length is " ${clubCoverImages.length}');
                          setState(() {});
                        },
                      );
                    }),
              ),
            )
                : const SizedBox.shrink(),
            clubCoverImages.length < 10
                ? InkWell(
                onTap: () async {
                  await chooseClubCoverImagesMethod();
                  MyPrint.printOnConsole('Club Cover Images Length: ${clubCoverImages.length}');
                  MyPrint.printOnConsole('Club Cover Images Type: ${clubCoverImages.first.runtimeType}');
                },
                child: const EmptyImageViewBox())
                : const SizedBox.shrink()
          ],
        )
      ],
    );
  }

  Widget getGalleryImages(){
    return Container();
  }

  Widget getAddClubButton() {
    return CommonButton(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            if (thumbnailImage == null && thumbnailImageUrl.checkEmpty) {
              MyToast.showError(context: context, msg: 'Please upload a club thumbnail image');
              return;
            }
            await addClub();
            Navigator.pop(context);
          }
        },
        text: 'Update Club Profile');
  }





}
