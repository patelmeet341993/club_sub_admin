import 'package:club_model/club_model.dart';
import 'package:club_model/models/club/data_model/club_operator_model.dart';


class ClubOperatorProvider extends CommonProvider{
  ClubOperatorProvider(){
    loggedInClubOperatorModel = CommonProviderPrimitiveParameter<ClubOperatorModel?>(
      value:null,
      notify: notify,
    );

    clubOperatorId =  CommonProviderPrimitiveParameter<String>(
      value:'',
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<ClubOperatorModel?> loggedInClubOperatorModel;
  late CommonProviderPrimitiveParameter<String> clubOperatorId;



// void setClubOperatorModel(ClubOperatorModel value, {bool isNotify = true}) {
  //   _loggedInClubOperatorModel = value;
  //   if (isNotify) {
  //     notifyListeners();
  //   }
  // }
}
