import 'dart:typed_data';


import 'package:club_model/club_model.dart';
import 'package:club_model/models/club/data_model/club_operator_model.dart';
import 'package:club_model/utils/my_print.dart';
import 'package:club_sub_admin/backend/club_products/club_products_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../../configs/constants.dart';
import 'club_products_provider.dart';

class ClubProductsController {
  late ClubProductsProvider clubProductsProvider;
  late ClubProductsRepository clubProductsRepository;

  ClubProductsController({required this.clubProductsProvider, ClubProductsRepository? repository}) {
    clubProductsRepository = repository ?? ClubProductsRepository();
  }

  Future<void> getProductsList({required List<String> productIds,bool isRefresh = true, bool isNotify = true}) async {
    try {

      if (!isRefresh && clubProductsProvider.clubProductList.length > 0) {
        MyPrint.printOnConsole("Returning Cached Data");
        clubProductsProvider.clubProductList;
      }

      if (isRefresh) {
        MyPrint.printOnConsole("Refresh");
        clubProductsProvider.clubProductIds.setList(list: productIds);
        clubProductsProvider.hasMoreClubProduct.set(value: true,isNotify: isNotify); // flag for more products available or not
        clubProductsProvider.clubProductLoading.set(value: false, isNotify: false);
        clubProductsProvider.clubProductList.setList(list: [], isNotify: isNotify);
      }

      if (!clubProductsProvider.hasMoreClubProduct.get()) {
        MyPrint.printOnConsole('No More Club Operators');
        return;
      }
      if (clubProductsProvider.clubProductLoading.get()) return;

      clubProductsProvider.clubProductLoading.set(value: true, isNotify: isNotify);

      List<String> methodLimitProducts = [];
      int currentIndex = clubProductsProvider.currentProductIndex.get();
      int limitIndex = currentIndex + MyAppConstants.clubProductDocumentLimitForPagination;
      List<String> methodProductIdList = clubProductsProvider.clubProductIds.getList();

      for(int i = currentIndex; i < limitIndex;i++){
        if(methodProductIdList.elementAtIndex(i) != null){
          methodLimitProducts.add(methodProductIdList.elementAtIndex(i)!);
        }
      }

      List<MyFirestoreQueryDocumentSnapshot> productDocs= await FirestoreController.getDocsFromCollection(collectionReference: FirebaseNodes.productsCollectionReference, docIds: methodLimitProducts);
      List<ProductModel> methodProductList = productDocs.map((e){return ProductModel.fromMap(e.data());}).toList();
      clubProductsProvider.clubProductList.setList(list: methodProductList, isClear: false);

      if (methodLimitProducts.length < MyAppConstants.clubProductDocumentLimitForPagination) clubProductsProvider.hasMoreClubProduct.set(value: false);
      clubProductsProvider.clubProductLoading.set(value: false);

      MyPrint.printOnConsole("Final Club Length From FireStore :${methodProductList.length}");
      MyPrint.printOnConsole("Final Club Length in Provider:${clubProductsProvider.clubProductList.length}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error in get Club List form Firebase in Club Controller $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> EnableDisableClubInFirebase({
    required bool adminEnabled,
    required String id,
    ClubModel? model,
  }) async {
    try {
      Map<String, dynamic> data = {
        MyAppConstants.cAdminEnabled: adminEnabled,
      };
      await FirebaseNodes.clubDocumentReference(clubId: id)
          .update(data);
      model?.adminEnabled = adminEnabled;

    } catch (e, s) {
      MyPrint.printOnConsole(
          "Error in Enable Disable Club in firebase in Club Controller $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> AddClubToFirebase(ClubModel clubModel,{bool isEdit = false}) async {
    try {
      await clubProductsRepository.AddClubRepo(clubModel);
      // if(!isEdit) clubProductsProvider.clubProductList.insertAtIndex(index: 0, model: clubModel);
    } catch (e, s) {
      MyPrint.printOnConsole(
          'Error in Add Club to Firebase in Club Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

  Future<ClubOperatorModel?> getClubOperatorFromId(String clubOperatorId) async {
    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.clubOperatorDocumentReference(clubOperatorId: clubOperatorId).get();
       if(snapshot.exists && snapshot.data().checkNotEmpty){
         return ClubOperatorModel.fromMap(snapshot.data()!);
       }
    } catch (e, s) {
      MyPrint.printOnConsole(
          'Error in Add Club to Firebase in Club Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> deleteClubFromFirebase(ClubModel clubModel) async {
    try {
      await clubProductsRepository.deleteClubRepo(clubModel);
      // clubProductsProvider.clubProductList.removeObject(model: clubModel);
    } catch (e, s) {
      MyPrint.printOnConsole(
          'Error in Remove Club From Firebase in Club Controller $e');
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
      print(e.toString());
    }

    return imageUrl;
  }
}
