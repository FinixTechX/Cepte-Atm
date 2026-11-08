import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './/App/App.dart';
import 'package:bloc/bloc.dart';
import './/injections.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await initInjections();
  BlocOverrides.runZoned(() {
    runApp(App());
  }, blocObserver: SimpleBlocObserver());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}
