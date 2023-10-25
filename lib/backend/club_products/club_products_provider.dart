import 'package:club_model/club_model.dart';

class ClubProductsProvider extends CommonProvider {
  ClubProductsProvider(){
    clubProductList = CommonProviderListParameter<ProductModel>(
      list: [],
      notify: notify,
    );
    clubProductCount = CommonProviderPrimitiveParameter<int>(
      value:0,
      notify: notify,
    );
    currentProductIndex = CommonProviderPrimitiveParameter<int>(
      value:0,
      notify: notify,
    );
    hasMoreClubProduct = CommonProviderPrimitiveParameter<bool>(
      value:false,
      notify: notify,
    );
    clubProductLoading = CommonProviderPrimitiveParameter<bool>(
      value:false,
      notify: notify,
    );
    clubProductsMap =  CommonProviderMapParameter<String,ProductModel>(
      map:{},
      notify: notify,
    );
    clubProductIds =  CommonProviderListParameter<String>(
      list:[],
      notify: notify,
    );
  }

  late CommonProviderListParameter<ProductModel> clubProductList;
  late CommonProviderPrimitiveParameter<int> clubProductCount;
  late CommonProviderPrimitiveParameter<int> currentProductIndex;
  late CommonProviderPrimitiveParameter<bool> hasMoreClubProduct;
  late CommonProviderPrimitiveParameter<bool> clubProductLoading;
  late CommonProviderMapParameter<String,ProductModel> clubProductsMap;
  late CommonProviderListParameter<String> clubProductIds;

  void addAllClubProductList(List<ProductModel> value,{bool isNotify = true}) {
    clubProductList.setList(list: value);
    if(isNotify) {
      notifyListeners();
    }
  }

  void addClubProductInList(ProductModel value,{bool isNotify = true}) {
    clubProductList.setList(list: [value],isClear: false);
    if(isNotify) {
      notifyListeners();
    }
  }

  void removeClubProductsFromList(int index,{bool isNotify = true}) {
    clubProductList.getList().removeAt(index);
    if(isNotify) {
      notifyListeners();
    }
  }

}

