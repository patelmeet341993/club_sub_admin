import 'package:club_model/club_model.dart';


class ClubProvider extends CommonProvider{
  ClubProvider(){
    loggedInClubModel = CommonProviderPrimitiveParameter<ClubModel?>(
      value:null,
      notify: notify,
    );

    clubId =  CommonProviderPrimitiveParameter<String>(
      value:'',
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<ClubModel?> loggedInClubModel;
  late CommonProviderPrimitiveParameter<String> clubId;

}
