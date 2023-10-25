import 'club_operator_provider.dart';
import 'club_operator_repository.dart';
import 'package:club_model/models/club/data_model/club_operator_model.dart';
import 'package:club_model/club_model.dart';


class ClubOperatorController{
  late ClubOperatorProvider clubOperatorProvider;
  late ClubOperatorRepository clubOperatorRepository;

  ClubOperatorController({required this.clubOperatorProvider, ClubOperatorRepository? repository}) {
    clubOperatorRepository = repository ?? ClubOperatorRepository();
  }

  Future<ClubOperatorModel?> getClubOperatorLogin({required String emailId,required String password}) async {
    try{
      ClubOperatorModel? model;
      MyPrint.printOnConsole("Id Pass: $emailId $password");

      final query = await FirebaseNodes.clubOperatorCollectionReference.where('emailId', isEqualTo: emailId).get();
      MyPrint.printOnConsole("query data: ${query.docs}");
      if (query.docs.isNotEmpty) {
        MyPrint.printOnConsole("doc is Not Empty");
        final doc = query.docs[0];
        MyPrint.printOnConsole("doc is Not Empty ${doc.data()}");
        model = ClubOperatorModel.fromMap(doc.data());
      }
      return model;
    }catch(e,s){
      MyPrint.printOnConsole('Error in getClubOperatorLogin in ClubOperatorController $e $s');
    }

  }

  Future<ClubOperatorModel?> getClubOperatorFromId(String clubOperatorId) async {
    try {
      ClubOperatorModel? model;
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.clubOperatorDocumentReference(clubOperatorId: clubOperatorId).get();
      if(snapshot.exists && snapshot.data().checkNotEmpty){
        model = ClubOperatorModel.fromMap(snapshot.data()!);
      }
      clubOperatorProvider.clubOperatorId.set(value: model?.id ?? '');
      clubOperatorProvider.loggedInClubOperatorModel.set(value: model);
      return model;
    } catch (e, s) {
      MyPrint.printOnConsole(
          'Error in getClubFromId in Club Controller $e');
      MyPrint.printOnConsole(s);
    }
  }


  }