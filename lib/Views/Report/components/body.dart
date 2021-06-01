import 'package:dima_colombo_ghiazzi/Views/Report/components/loadingDialog.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/reportFormBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => ReportFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<ReportFormBloc>(context);
          return Theme(
              data: Theme.of(context).copyWith(
                primaryColor: Colors.indigo[400], //Color(0xFFD6C1FF),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              child: Scaffold(
                  appBar: AppBar(title: Text('Anonymous report')),
                  body: FormBlocListener<ReportFormBloc, String, String>(
                    onSubmitting: (context, state) {
                      LoadingDialog.show(context);
                    },
                    onSuccess: (context, state) {
                      LoadingDialog.hide(context);

                      //Add what to do
                    },
                    onFailure: (context, state) {
                      LoadingDialog.hide(context);

                      //Add what to do
                    },
                    child: Container(
                      width: double.infinity,
                      height: size.height,
                      child: Stack(
                          alignment: Alignment.lerp(
                              Alignment.topCenter, Alignment.center, 0.7),
                          children: <Widget>[
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Image.asset(
                                "assets/images/main_top.png",
                                width: size.width * 0.35,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Image.asset(
                                "assets/images/login_bottom.png",
                                width: size.width * 0.4,
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/icons/safety.png",
                                    height: size.height * 0.15,
                                  ),
                                  DropdownFieldBlocBuilder<String>(
                                    selectFieldBloc: formBloc.reportCategory,
                                    decoration: InputDecoration(
                                      labelText: 'Report category',
                                      prefixIcon: Icon(Icons.security),
                                    ),
                                    itemBuilder: (context, value) => value,
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.reportText,
                                    decoration: InputDecoration(
                                      labelText: 'Report description',
                                      prefixIcon: Icon(Icons.text_fields),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      formBloc.submit();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.indigoAccent[400],
                                      shadowColor: Colors.indigo[400],
                                    ),
                                    child: Text('SUBMIT'),
                                  )
                                ],
                              ),
                            ),
                            /*child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        DropdownFieldBlocBuilder<String>(
                          selectFieldBloc: formBloc.reportCategory,
                          decoration: InputDecoration(
                            labelText: 'Report category',
                            prefixIcon: Icon(Icons.security),
                          ),
                          itemBuilder: (context, value) => value,
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.reportText,
                          decoration: InputDecoration(
                            labelText: 'Report description',
                            prefixIcon: Icon(Icons.text_fields),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),*/
                          ]),
                    ),
                  )));
        },
      ),
    );
  }
}
