import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progiom_cms/auth.dart';
import 'package:progiom_cms/homeSettings.dart';
import '../../constants.dart';
import './/Utils/AppSnackBar.dart';
import './/Utils/SizeConfig.dart';
import '../../injections.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late HomeSettingsWrapper homeSettingsWrapper;
  final GlobalKey<_SplashContentState> splashKey =
      GlobalKey<_SplashContentState>();

  _getGeoLocation() async {
    Position position = await _getGeoLocationPosition();
    positionMarker = LatLng(position.latitude, position.longitude);
    kGooglePlex = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    );
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    _getGeoLocation();
    homeSettingsWrapper = HomeSettingsWrapper(
      successCallback: goToHomePage,
      failureCallback: failledToGetSettings,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AuthWrapper(
        onTokenReady: (isafterLogout, {token}) {
          if (!isafterLogout) {
            homeSettingsWrapper.getSettings();
          }
        },
        onErrorInToken: (error) =>
            AppSnackBar.show(context, error, ToastType.Error),
        authBloc: sl<AuthBloc>(),
        child: homeSettingsWrapper
          ..child = SplashContent(
            key: splashKey,
          ));
  }

  failledToGetSettings(String error) {
    AppSnackBar.show(context, error, ToastType.Error);
  }

  goToHomePage() {
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      splashKey.currentState?.setState(() {
        splashKey.currentState?.done = true;
      });
    });
  }
}

class SplashContent extends StatefulWidget {
  SplashContent({
    Key? key,
  }) : super(key: key);

  @override
  _SplashContentState createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent> {
  Tween<double> tween = Tween<double>(begin: 1.0, end: 0.0);
  Duration duration = Duration(milliseconds: 200);
  Curve curve = Curves.fastOutSlowIn;
  bool done = false;
  bool navigateInAfterEnd = false;
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      onEnd: () {
        if (mounted) {
          if (navigateInAfterEnd) {
            if (sl<AuthBloc>().isFirstLaunch) {
              Navigator.pushReplacementNamed(context, '/onboard');
            } else if (sl<AuthBloc>().isGuest) {
              Navigator.pushReplacementNamed(context, '/login');
            } else {
              Navigator.pushReplacementNamed(context, '/base');
            }
          } else if (done) {
            setState(() {
              tween = Tween<double>(begin: tween.begin, end: 0.9);
              duration = Duration(milliseconds: 200);
              navigateInAfterEnd = true;
              curve = Curves.linear;
            });
          } else {
            setState(() {
              tween = Tween<double>(
                  begin: tween.begin == 1.0 ? 0.05 : 1.0,
                  end: tween.end == 0.0 ? 0.05 : 0.0);
              duration = Duration(milliseconds: 200);
              curve = Curves.easeInOutQuad;
            });
          }
        }
      },
      builder: (BuildContext context, double? value, Widget? child) {
        return Scaffold(
            body: Stack(children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFFFAF9F6),
            child: Image.asset(
              'assets/splashBg.png',
              fit: BoxFit.fill,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: SizeConfig.w(100),
                child: Center(
                  child: Image.asset(
                    'assets/splashIcon.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ]));
      },
      duration: duration,
      tween: tween,
      curve: curve,
    );
  }
}
