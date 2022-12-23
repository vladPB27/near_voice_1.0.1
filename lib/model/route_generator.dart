import 'package:flutter/material.dart';
import 'package:near_voice/view/client/connect_meeting.dart';
import 'package:near_voice/view/create_loading.dart';
import 'package:near_voice/view/info_popup.dart';
import 'package:near_voice/view/info_popup_two.dart';
import 'package:near_voice/view/practicas/crear_sala.dart';
import 'package:near_voice/view/practicas/test_soundstream.dart';
import 'package:near_voice/view/server/create_meeting.dart';
import 'package:near_voice/view/home.dart';
import 'package:near_voice/view/launch_screen.dart';
import 'package:near_voice/view/login.dart';
import 'package:near_voice/main.dart';
import 'package:near_voice/view/server/meet_created.dart';
import 'package:near_voice/view/client/meet_join_client.dart';
import 'package:near_voice/view/profile.dart';
import 'package:near_voice/view/client/users_connected_client.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LaunchScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => Home());
      case '/createMeeting':
        return MaterialPageRoute(builder: (_) => CreateMeeting());
      case '/connectMeeting':
        return MaterialPageRoute(builder: (_) => ConnectMeeting());
      case '/meetcreated':
        return MaterialPageRoute(builder: (_) => MeetCreated());
      case '/meetjoin':
        return MaterialPageRoute(builder: (_) => MeetJoin());
      case '/profile':
        return MaterialPageRoute(builder: (_) => Profile(data:args));
      case '/info_popup':
        return MaterialPageRoute(builder: (_) => InfoPopUp());
      case '/create_loading':
        return MaterialPageRoute(builder: (_) => CreateLoading());
      case '/info_popup_two':
        return MaterialPageRoute(builder: (_) => InfoPopUpTwo());
      case '/testing_sound_stream':
        return MaterialPageRoute(builder: (_) => TestingSoundStream());
      case '/crearSala_practicas':
        return MaterialPageRoute(builder: (_) => CrearSala());
      case '/login':
        return MaterialPageRoute(builder: (_) => Login());
      // case '/users':
      //   return MaterialPageRoute(builder: (_) => Users());
      case '/third':
        // if (args is String){
        //   return MaterialPageRoute(
        //       builder: (_) => InitialPage(
        //         data:args, //data es del la otra vista
        //       ),
        //   );
        // }
      //   return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Error'),
          ),
          body: Center(
          child: Text('ERROR'),
      ),
      );
    });
  }
}