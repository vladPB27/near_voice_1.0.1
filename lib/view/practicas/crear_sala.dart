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
    return Scaffold(
        appBar: AppBar(
          // title: Text('Server'),
          title: Text('Cliente'),
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
                  // hintText: 'Ingrese una direccion IP',
                  hintText: 'Ingrese la direccion IP del host',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 100,right: 100),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/testing_sound_stream');
                },
                // child: Text('Crear',style: TextStyle(
                child: Text('Unirse',style: TextStyle(
                    color: Colors.white
                ),),
                style: TextButton.styleFrom(
                  backgroundColor: ColorsNearVoice.primaryColor,
                  fixedSize: const Size(20, 40),
                ),
              ),
            )
          ],
        ),
      );
  }
}
