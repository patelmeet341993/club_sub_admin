import 'package:club_model/club_model.dart';
import 'package:club_sub_admin/models/edit_club_request_model.dart';

class ClubRepository {
  Future<List<ClubModel>> getClubListRepo() async {
    List<ClubModel> clubList = [];

    try {
      MyFirestoreQuerySnapshot querySnapshot =
          await FirebaseNodes.clubsCollectionReference.get();
      if (querySnapshot.docs.isNotEmpty) {
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot
            in querySnapshot.docs) {
          if (queryDocumentSnapshot.data().isNotEmpty) {
            clubList.add(ClubModel.fromMap(queryDocumentSnapshot.data()));
          } else {
            MyPrint.printOnConsole(
                "Club Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    } catch (e, s) {
      MyPrint.printOnConsole('Error in getClubListRepo in ClubRepository $e');
      MyPrint.printOnConsole(s);
    }

    return clubList;
  }

  Future<void> editClubRepo(EditClubRequestModel editClubRequestModel) async {
    try {
      await FirebaseNodes.clubDocumentReference(clubId: editClubRequestModel.id)
          .update(editClubRequestModel.toMap());
    } catch (e, s) {
      MyPrint.printOnConsole("Error in delete check admin login method in admin Repository $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<ClubModel?> checkLoginClubMethod({required String adminId, required String password}) async {
    try {
      ClubModel? clubModel;
      MyPrint.printOnConsole("query id: $adminId password: $password");

      final query = await FirebaseNodes.clubsCollectionReference.where('clubOwners', isEqualTo: [{adminId : password}]).get();

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
