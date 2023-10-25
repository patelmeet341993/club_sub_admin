import 'dart:typed_data';


import 'package:club_model/club_model.dart';
import 'package:club_model/utils/my_print.dart';
import 'package:club_sub_admin/backend/club_backend/club_provider.dart';
import 'package:club_sub_admin/models/edit_club_request_model.dart';
import 'package:image_picker/image_picker.dart';

import '../../configs/constants.dart';
import 'club_repository.dart';

class ClubController {
  late ClubProvider clubProvider;
  late ClubRepository clubRepository;


  ClubController({required this.clubProvider, ClubRepository? repository}) {
    clubRepository = repository ?? ClubRepository();
  }

  Future<ClubModel?> getClubFromId(String clubId) async {
    try {
      ClubModel? model;
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.clubDocumentReference(clubId: clubId).get();
      if(snapshot.exists && snapshot.data().checkNotEmpty){
        model = ClubModel.fromMap(snapshot.data()!);
      }
      clubProvider.clubId.set(value: model?.id ?? '');
      clubProvider.loggedInClubModel.set(value: model);
      return model;
    } catch (e, s) {
      MyPrint.printOnConsole(
          'Error in getClubFromId in Club Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

  Future<String> uploadImageToFirebase(XFile imageFile, {String clubId = ""}) async {
    String imageUrl = "";

    try {
      // Create a unique filename for the image
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Uint8List? imageData  = await imageFile.readAsBytes();
      String type = imageFile.mimeType?.split("/").last ?? "";
      // Reference the Firebase Storage location to upload the file
      String path = clubId.isEmpty ? "ClubImages/$fileName.$type" : "ClubImages/$clubId/$fileName.$type";
      Reference storageReference = FirebaseStorage.instance.ref().child(path);


      // Upload the image file to Firebase Storage
      UploadTask uploadTask = storageReference.putData(imageData, SettableMetadata(contentType: imageFile.mimeType));
      await uploadTask.whenComplete(() {});

      // Retrieve the download URL of the uploaded image
      imageUrl = await storageReference.getDownloadURL();
    } catch (e) {
      MyPrint.printOnConsole(e.toString());
    }

    return imageUrl;
  }

  Future<void> updateClubModelToFirebase(EditClubRequestModel editClubRequestModel) async {
    try {
      await clubRepository.editClubRepo(editClubRequestModel);
      if(clubProvider.loggedInClubModel.get() == null){
        return;
      }

      clubProvider.loggedInClubModel.get()!.name = editClubRequestModel.name;

    } catch (e, s) {
      MyPrint.printOnConsole(
          'Error in Add Club Operator to Firebase in Club Controller $e');
      MyPrint.printOnConsole(s);
    }
  }


}
