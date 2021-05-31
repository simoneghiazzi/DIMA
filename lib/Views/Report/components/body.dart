import 'package:dima_colombo_ghiazzi/Views/Report/components/loadingDialog.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/reportFormBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<ReportFormBloc>(context);

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
                child: SingleChildScrollView(
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
