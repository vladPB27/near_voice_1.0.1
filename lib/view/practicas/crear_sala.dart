import 'package:flutter/material.dart';
import 'package:near_voice/model/colors.dart';

class CrearSala extends StatefulWidget {
  const CrearSala({key}) : super(key: key);

  @override
  _CrearSalaState createState() => _CrearSalaState();
}

class _CrearSalaState extends State<CrearSala> {
  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Server'),
          elevation: 0,
          backgroundColor: ColorsNearVoice.primaryColor,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                // textAlign: TextAlign.center,
                controller: nameController,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  hintText: 'Ingrese una direccion IP',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 100,right: 100),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/testing_sound_stream');
                },
                child: Text('Crear'),
                style: TextButton.styleFrom(
                  backgroundColor: ColorsNearVoice.primaryColor,
                  fixedSize: const Size(20, 40),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
