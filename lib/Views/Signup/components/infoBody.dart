import 'package:dima_colombo_ghiazzi/ViewModel/authViewModel.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/infoViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class InfoBody extends StatelessWidget {
  final AuthViewModel authViewModel;

  InfoBody({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => InfoViewModel(authViewModel: authViewModel),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<InfoViewModel>(context);
          return Theme(
              data: Theme.of(context).copyWith(
                primaryColor: Colors.indigo[400],
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              child: Scaffold(
                  appBar: AppBar(title: Text('Personal informations')),
                  body: FormBlocListener<InfoViewModel, String, String>(
                    onSubmitting: (context, state) {
                      //LoadingDialog.show(context);
                    },
                    onSuccess: (context, state) {
                      //LoadingDialog.hide(context);
                      //_onReportSubmitted(context);
                    },
                    onFailure: (context, state) {
                      //LoadingDialog.hide(context);

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
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/icons/logo.png",
                                    height: size.height * 0.15,
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.nameText,
                                    decoration: InputDecoration(
                                      labelText: 'First name',
                                      prefixIcon: Icon(Icons.text_fields),
                                    ),
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.surnameText,
                                    decoration: InputDecoration(
                                      labelText: 'Last name',
                                      prefixIcon: Icon(Icons.text_fields),
                                    ),
                                  ),
                                  DateTimeFieldBlocBuilder(
                                    dateTimeFieldBloc: formBloc.birthDate,
                                    format: DateFormat('dd-MM-yyyy'),
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1921),
                                    lastDate: DateTime.now()
                                        .subtract(const Duration(days: 5844)),
                                    decoration: InputDecoration(
                                      labelText: 'Birth date',
                                      prefixIcon: Icon(Icons.date_range),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      formBloc.submit();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.indigoAccent[400],
                                    ),
                                    child: Text('NEXT'),
                                  )
                                ],
                              ),
                            ),
                          ]),
                    ),
                  )));
        },
      ),
    );
  }
}
