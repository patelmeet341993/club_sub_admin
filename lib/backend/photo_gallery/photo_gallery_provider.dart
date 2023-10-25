
import 'package:club_model/backend/common/common_provider.dart';
import 'package:club_model/models/club/data_model/club_model.dart';

class PhotoGalleryProvider extends CommonProvider {
  PhotoGalleryProvider() {
    photoGalleryModelList = CommonProviderListParameter<GallerySection>(
      list: [],
      notify: notify,
    );
  }

  late CommonProviderListParameter<GallerySection> photoGalleryModelList;

}
