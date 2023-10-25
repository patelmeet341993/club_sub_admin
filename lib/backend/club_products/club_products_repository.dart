import 'package:club_model/club_model.dart';

class ClubProductsRepository {
  Future<List<ProductModel>> getClubProductsListRepo(List<String> productList) async {
    List<ProductModel> clubProductsList = [];

    try {
      MyFirestoreDocumentSnapshot documentSnapshot = await FirebaseNodes.clubDocumentReference(clubId: 'clubId').get();
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
          // photoGalleryProvider.photoGalleryModelList.setList(list: galleryList);
        }
      }
    } catch (e, s) {
      MyPrint.printOnConsole('Error in getClubListRepo in ClubRepository $e');
      MyPrint.printOnConsole(s);
    }

    return clubProductsList;
  }

  Future<void> AddClubRepo(ClubModel clubModel) async {
    await FirebaseNodes.clubDocumentReference(clubId: clubModel.id)
        .set(clubModel.toMap());
  }

  Future<void> deleteClubRepo(ClubModel clubModel) async {
    await FirebaseNodes.clubDocumentReference(clubId: clubModel.id)
        .delete();
  }

  Future<ClubModel?> checkLoginClubMethod({required String adminId, required String password}) async {
    try {
      ClubModel? clubModel;
      MyPrint.printOnConsole("query id: $adminId password: $password");

      final query = await FirebaseNodes.clubsCollectionReference.where('userId', isEqualTo: adminId).where('password', isEqualTo: password).get();

      MyPrint.printOnConsole("query data: ${query.docs}");

      if (query.docs.isNotEmpty) {
        MyPrint.printOnConsole("doc is Not Empty");
        final doc = query.docs[0];
        MyPrint.printOnConsole("doc is Not Empty ${doc.data()}");
        MyPrint.printOnConsole("doc is Not Empty Inside if");

        clubModel = ClubModel.fromMap(doc.data());
      }
      MyPrint.printOnConsole("query id model: $clubModel");
      return clubModel;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in delete check admin login method in admin Repository $e");
      MyPrint.printOnConsole(s);
    }
    return null;
  }
}
