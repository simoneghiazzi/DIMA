/*import 'package:dear_diary/view_model/base.dart';
import 'package:dear_diary/view_model/entry.dart';*/
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

//import '../home.dart';

class AddEntry extends StatefulWidget {
  static const routeName = 'add-entry';

  AddEntry({Key key}) : super(key: key);

  _AddEntryState createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  Map<String, String> _formData = {};
  final _addEntryFormKey = GlobalKey<FormState>();
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          TopBar(
            text: 'New page',
          ),
          Form(
            key: _addEntryFormKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 3,
                    cursorColor: Color(0xFF3C4858),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'What\'s our topic of discussion?',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    //validator: DiaryViewModel.title,
                    onSaved: (value) => _formData['title'] = value,
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  cursorColor: Color(0xFF3C4858),
                  decoration: InputDecoration.collapsed(
                      hintText: 'Tell me about it...'),
                  //validator: DiaryViewModel.content,
                  onSaved: (value) => _formData['content'] = value,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF3C4858),
        child:
            /*Provider.of<EntryViewModel>(context).viewStatus ==
                ViewStatus.Loading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              )
            :*/
            Icon(
          Icons.check,
          semanticLabel: 'Save',
        ),
        onPressed: () {
          /*if (Provider.of<EntryViewModel>(context).viewStatus ==
              ViewStatus.Loading) return;
          final form = _addEntryFormKey.currentState;
          if (form.validate()) {
            form.save();
            _handleAddEntry();
          }*/
        },
      ),
    );
  }

  /*_handleAddEntry() async {
    final response = await Provider.of<EntryViewModel>(context, listen: false)
        .create(_formData);
    if (response) {
      Navigator.of(context).pushNamed(Home.routeName);
    }
  }*/
}
