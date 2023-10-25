import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_model/utils/my_utils.dart';
import 'package:club_model/utils/parsing_helper.dart';
import 'package:club_model/models/location/data_model/location_model.dart';



class EditClubRequestModel {
  String id = "";
  String name = "";
  String thumbnailImageUrl = "";
  String mobileNumber = "";
  String address = "";
  List<String> coverImages = <String>[];
  List<GallerySection> galleryImages = <GallerySection>[];
  Timestamp? createdTime;
  Timestamp? updatedTime;
  LocationModel? location;

  EditClubRequestModel({
    this.id = "",
    this.name = "",
    this.thumbnailImageUrl = "",
    this.mobileNumber = "",
    this.address = "",
    List<String>? coverImages,
    List<GallerySection>? galleryImages,
    this.createdTime,
    this.updatedTime,
    this.location,
  }) {
    this.coverImages = coverImages ?? <String>[];
    this.galleryImages = galleryImages ?? <GallerySection>[];
  }

  EditClubRequestModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    thumbnailImageUrl = ParsingHelper.parseStringMethod(map['thumbnailImageUrl']);
    mobileNumber = ParsingHelper.parseStringMethod(map['mobileNumber']);
    address = ParsingHelper.parseStringMethod(map['address']);
    coverImages = ParsingHelper.parseListMethod<dynamic, String>(map['coverImages']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);

    List<Map<String,dynamic >> galleryImagesList = ParsingHelper.parseMapsListMethod(map['galleryImages']);
    galleryImages = galleryImagesList.map((e){
      return GallerySection.fromMap(e);
    }).toList();


    location = null;
    Map<String, dynamic> locationMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['location']);
    if(locationMap.isNotEmpty) {
      location = LocationModel.fromMap(locationMap);
    }
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "thumbnailImageUrl" : thumbnailImageUrl,
      "mobileNumber" : mobileNumber,
      "address" : address,
      "coverImages" : coverImages,
      "galleryImages" : galleryImages.map((e) => e.toMap(toJson: toJson)).toList(),
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
      "location" : location?.toMap(toJson: toJson),
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}

class GallerySection {
  String imageUrl = '';
  String sectionName = '';
  Timestamp? createdTime;

  GallerySection({
    this.imageUrl = "",
    this.sectionName = "",
    this.createdTime,
  });

  GallerySection.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    sectionName = ParsingHelper.parseStringMethod(map['sectionName']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "imageUrl" : imageUrl,
      "sectionName" : sectionName,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}