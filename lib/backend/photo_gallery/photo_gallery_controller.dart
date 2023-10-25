
import 'package:club_model/utils/my_print.dart';
import 'package:club_sub_admin/backend/photo_gallery/photo_gallery_provider.dart';
import 'package:club_model/club_model.dart';

class PhotoGalleryController {
  late PhotoGalleryProvider photoGalleryProvider;

  PhotoGalleryController({required this.photoGalleryProvider});

  Future<void> addPhotoGalleryFirebase(GallerySection gallerySection,String clubId,{bool isEdit = false}) async {
    try {
    await FirebaseNodes.clubDocumentReference(clubId: clubId)
        .update({'galleryImages.${gallerySection.id}' :  gallerySection.toMap()});
      // if(!isEdit) photoGalleryProvider.clubOperatorList.insertAtIndex(index: 0, model: clubOperatorModel);
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Add Club Operator to Firebase in Club Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> removePhotoGalleryFirebase(GallerySection gallerySection,String clubId,{bool isEdit = false}) async {
    try {
    await FirebaseNodes.clubDocumentReference(clubId: clubId)
        .update({'galleryImages.${gallerySection.id}' : FieldValue.delete()});
      // if(!isEdit) photoGalleryProvider.clubOperatorList.insertAtIndex(index: 0, model: clubOperatorModel);
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Add Club Operator to Firebase in Club Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> getGallerySectionList(String clubId) async {
    try {

      MyFirestoreDocumentSnapshot documentSnapshot = await FirebaseNodes.clubDocumentReference(clubId: clubId).get();
      MyPrint.printOnConsole(
        "snapshot exist:${documentSnapshot.exists}",
      );
      MyPrint.printOnConsole(
        "snapshot data:${documentSnapshot.data()}",
      );

      if (documentSnapshot.data() != null && (documentSnapshot.data()?.isNotEmpty ?? false)) {

        ClubModel clubModel = ClubModel.fromMap(documentSnapshot.data()!);
        List<GallerySection> galleryList = [];
        if(clubModel.galleryImages.isNotEmpty){
          galleryList.addAll(clubModel.galleryImages.values);
        }
        if(galleryList.isNotEmpty){
          photoGalleryProvider.photoGalleryModelList.setList(list: galleryList);
        }
      }
      // if(!isEdit) photoGalleryProvider.clubOperatorList.insertAtIndex(index: 0, model: clubOperatorModel);
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Add Club Operator to Firebase in Club Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

}
