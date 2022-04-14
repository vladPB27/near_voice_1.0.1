import 'package:flutter/material.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:near_voice/widgets/image_customize_profile.dart';
import 'package:provider/provider.dart';

import 'login.dart';

class Profile extends StatefulWidget {
  final String data;

  Profile({
    Key key,
    @required this.data,
  }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('PROFILE SCREEN');
    final userInfo = Provider.of<User>(context, listen: false);
    final nameController = TextEditingController(text: userInfo.name);
    final statusController = TextEditingController(text: userInfo.status);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: ColorsNearVoice.primaryColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              _exitDialog(nameController.text, statusController.text);
            },
          ),
          title: Text('Profile',style: TextStyle(
            fontFamily: 'OverpassBold',
              fontSize: 24
          ),),
          backgroundColor: ColorsNearVoice.primaryColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ImageCustomizeProfile()),
                    ),
                    Expanded(
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(top: 20, left: 50, right: 50),
                                child: Container(
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.center,
                                    // textAlign: TextAlign.center,
                                    controller: nameController,
                                    validator: (value) => value.trim().length == 0
                                        ? 'Enter your name'
                                        : null,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 25),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30.0),
                                        ),
                                      ),
                                      hintText: 'Name',
                                    ),
                                  ),
                                  // height: 50,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: 10, left: 50, right: 50, top: 20),
                                child: Container(
                                  // height: 50,
                                  child: TextFormField(
                                    controller: statusController,
                                    validator: (value) => value.trim().length == 0
                                        ? 'Enter your status'
                                        : null,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 25),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30.0))),
                                        hintText: 'How are you?'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: ColorsNearVoice.primaryColor,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: Icon(
                          Icons.person_outline,
                          size: 35,
                          color: Colors.white,
                        )),
                        Text(
                          'Profile',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: 35,
                            color: Colors.white70,
                          ),
                          onPressed: () {},
                        ),
                        Text(
                          'Create',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: Icon(
                          Icons.people_alt_outlined,
                          size: 35,
                          color: Colors.white70,
                        )),
                        Text(
                          'Connect',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _exitDialog(String name, String status) {
    final heightDialog = MediaQuery.of(context).size.height * 0.23;
    final widthDialog = MediaQuery.of(context).size.width * 0.75;

    final userInfo = Provider.of<User>(context, listen: false);

    return showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: widthDialog,
            height: heightDialog,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: ColorsNearVoice.primaryColor),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Do you want to save your changes?',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'OverpassRegular',
                            decoration: TextDecoration.none
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final form = formKey.currentState;
                              if(form.validate()){
                                userInfo.name = name;
                                userInfo.status = status;
                                // userInfo.image = image;
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }
                              else{
                                Navigator.of(context).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                ),
                              ),
                              elevation: 7,
                              primary: ColorsNearVoice.thirdColor,
                              minimumSize:
                                  Size(widthDialog / 2, heightDialog / 3),
                            ),
                            child: Text('Yes',style: TextStyle(fontFamily: 'OverpassBold',
                              fontSize: 18
                            ),),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                elevation: 7,
                                minimumSize:
                                    Size(widthDialog / 2, heightDialog / 3),
                                // primary: ColorsNearVoice.primaryColor,
                                primary: ColorsNearVoice.primaryColor,
                                onPrimary: Colors.white),
                            child: Text('No',style: TextStyle(fontFamily: 'OverpassBold',
                                fontSize: 18
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
