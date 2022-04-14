import 'dart:async';
import 'package:flutter/material.dart';
import 'package:near_voice/model/providers/actions_widget.dart';
import 'package:near_voice/model/providers/meeting.dart';
import 'package:near_voice/model/route_generator.dart';
import 'package:near_voice/model/providers/user.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActionsWidget()),
        ChangeNotifierProvider(create: (_) => User()),
        ChangeNotifierProvider(create: (_) => Meeting()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // themeMode: ThemeMode.dark,
        title: 'nearvoice',
        theme: ThemeData(fontFamily: 'OverpassRegular'),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}

