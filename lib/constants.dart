import 'package:CepteATM/Ui/Home/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String BaseUrl = "https://cepteatm.com/";
const String ClientPersonalSecret = "32ScMm7X7frEFHcOi5kGMWGjRU4vE6XeUQ90u4sS";
const String ClientPersonalId = "9";

const String ClientPasswordSecret = "JfLzPEtjIGzSOXa7xAtRMs3X6X57nwDvG1ra3dqE";
const String ClientPasswordId = "10";

const String IS_LOGIN = "login";
const String ID = "id";
const String NAME = "name";
const String PASSWORD = "password";
const String EMAIL = "email";
const String TOKEN = "token";
const String EXPIRESIN = "expiresIn";
const String IMAGE = "image";
const String COVER_IMAGE = "coverImage";
const String ADDRESS = "address";
const String WEBSITE = "webSite";
const String MOBILE = "mobile";
const String SLUG = "slug";
const String PROFILE_IMAGE = "profileImage";
const String PlacholderImageUrl = "https://via.placeholder.com/150";

const logoPlaceholder = AssetImage("assets/loader.gif");

LatLng? positionMarker;
var sizeMarker = 50.0;
CameraPosition kGooglePlex = CameraPosition(
  target: LatLng(24.70966834713882, 46.67524069547653),
  zoom: 15,
);

bool isBuildAdd = false;
bool isBuildHome = false;
bool isBuildHis = false;
final GlobalKey<HomePageState> homePageStateKey = GlobalKey();
