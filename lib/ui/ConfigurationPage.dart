import 'package:flutter/material.dart';



class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({Key? key}) : super(key: key);

  @override
  State<ConfigurationPage> createState() => _ConfigurationPage();
}

class _ConfigurationPage extends State<ConfigurationPage> {
  Color background_grid_module = Color(0xffF5EFFF);
  Color font_in_grid_module = Color(0XFF7371FC);

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFF7371FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('CONFIGURAÇÕES'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 4,
      ),
      body: Center(
        child: ListView(children: [
          Container(
            height: 200,
            width: 55,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background_grid_module,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff5C5BB4).withOpacity(0.5),
                  spreadRadius: 7,
                  blurRadius: 6,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListView(
              children: [
                Row(
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Icon(Icons.account_circle_outlined,
                          size: 30, color: background_grid_module),
                      decoration: BoxDecoration(
                          color: font_in_grid_module,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    Expanded(
                      // height: 55,
                      // alignment: Alignment.centerLeft,
                      child: Text(
                        'Perfil',
                        maxLines: 3,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20,
                            color: font_in_grid_module,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 328,
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                  child: Text(
                                    'Editar Perfil',
                                    maxLines: 3,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: font_in_grid_module,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                height: 40,
                                alignment: Alignment.centerLeft,
                                child: Icon(Icons.keyboard_arrow_right,
                                    color: font_in_grid_module,),
                              ),
                            ],
                          )),
                          InkWell(
                            onTap: () {
                              print("Editar Perfil");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Divider(color: font_in_grid_module)),
                Row(
                  children: [
                    SizedBox(
                      width: 328,
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                      child: Text(
                                        'Mudar senha',
                                        maxLines: 3,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: font_in_grid_module,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    height: 40,
                                    alignment: Alignment.centerLeft,
                                    child: Icon(Icons.keyboard_arrow_right,
                                        color: font_in_grid_module),
                                  ),
                                ],
                              )),
                          InkWell(
                            onTap: () {
                              print("Mudar senha");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            width: 55,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background_grid_module,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff5C5BB4).withOpacity(0.5),
                  spreadRadius: 7,
                  blurRadius: 6,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListView(
              children: [
                Row(
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Icon(Icons.add_box_outlined,
                          size: 30, color: background_grid_module),
                      decoration: BoxDecoration(
                          color: font_in_grid_module,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    Expanded(
                      // height: 55,
                      // alignment: Alignment.centerLeft,
                      child: Text(
                        'Outros',
                        maxLines: 3,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20,
                            color: font_in_grid_module,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 328,
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                      child: Text(
                                        'Idioma',
                                        maxLines: 3,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: font_in_grid_module,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    height: 40,
                                    alignment: Alignment.centerLeft,
                                    child: Icon(Icons.keyboard_arrow_right,
                                        color: font_in_grid_module),
                                  ),
                                ],
                              )),
                          InkWell(
                            onTap: () {
                              print("Idioma");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Divider(color: font_in_grid_module)),
                Row(
                  children: [
                    SizedBox(
                      width: 328,
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                      child: Text(
                                        'País',
                                        maxLines: 3,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: font_in_grid_module,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    height: 40,
                                    alignment: Alignment.centerLeft,
                                    child: Icon(Icons.keyboard_arrow_right,
                                        color: font_in_grid_module),
                                  ),
                                ],
                              )),
                          InkWell(
                            onTap: () {
                              print("País");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
