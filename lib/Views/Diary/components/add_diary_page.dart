/*import 'package:dear_diary/view_model/base.dart';
import 'package:dear_diary/view_model/entry.dart';*/
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:provider/provider.dart';

class AddEntry extends StatefulWidget {
  static const routeName = 'add-entry';

  AddEntry({Key key}) : super(key: key);

  _AddEntryState createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry>
    with SingleTickerProviderStateMixin {
  AnimationController _optionsAnimationController;
  Animation<Offset> _optionsAnimation, _optionsDelayedAnimation;
  bool _optionsIsOpen = false;

  @override
  void initState() {
    super.initState();
    _optionsAnimationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _optionsAnimation = Tween<Offset>(begin: Offset(100, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _optionsAnimationController, curve: Curves.easeOutBack))
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener(_setOptionsStatus);
    _optionsDelayedAnimation =
        Tween<Offset>(begin: Offset(100, 0), end: Offset(0, 0)).animate(
            CurvedAnimation(
                parent: _optionsAnimationController,
                curve: Interval(0.2, 1.0, curve: Curves.easeOutBack)));
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> _formData = {};
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: 340.0,
                    width: size.width,
                    child: Image.asset(
                      'assets/icons/logo.png',
                    ),
                  ),
                  Positioned(
                    top: 200.0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      alignment: Alignment.bottomLeft,
                      child: TextFormField(
                        cursorColor: kPrimaryColor,
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.white,
                              ),
                            ]),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            hintText: 'What\'s our topic of discussion?',
                            hintStyle: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 3.0,
                                    color: Colors.white,
                                  ),
                                ])),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        //validator: DiaryViewModel.title,
                        onSaved: (value) => _formData['title'] = value,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 300.0,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(100.0),
                              topLeft: Radius.circular(100.0)),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(.4),
                              offset: Offset(0.0, -8),
                              blurRadius: 6,
                            )
                          ]),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 50.0),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(color: kPrimaryColor, fontSize: 20),
                  maxLines: null,
                  cursorColor: Color(0xFF3C4858),
                  decoration: InputDecoration.collapsed(
                      hintText: 'Tell me about it...',
                      hintStyle: TextStyle(color: kPrimaryColor, fontSize: 20)),
                  //validator: DiaryViewModel.content,
                  onSaved: (value) => _formData['content'] = value,
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: InkResponse(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimaryColor.withOpacity(.5),
                            offset: Offset(1.0, 10.0),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Icon(Icons.arrow_back, color: kPrimaryColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setOptionsStatus(AnimationStatus status) {
    setState(() {
      _optionsIsOpen = status == AnimationStatus.forward ||
          status == AnimationStatus.completed;
    });
  }

  @override
  void dispose() {
    _optionsAnimationController.dispose();
    super.dispose();
  }
}

class EntryHeaderImage extends StatelessWidget {
  final String heroTag;
  final ImageProvider imageProvider;

  const EntryHeaderImage({
    Key key,
    this.heroTag,
    this.imageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: imageProvider,
      child: Container(
        height: 340.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
              colorFilter:
                  ColorFilter.mode(Color(0xFF3C4858), BlendMode.lighten),
              image: imageProvider,
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  /*
  Map<String, String> _formData = {};
  final _addEntryFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _optionsAnimationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _optionsAnimation = Tween<Offset>(begin: Offset(100, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _optionsAnimationController, curve: Curves.easeOutBack))
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener(_setOptionsStatus);
    _optionsDelayedAnimation =
        Tween<Offset>(begin: Offset(100, 0), end: Offset(0, 0)).animate(
            CurvedAnimation(
                parent: _optionsAnimationController,
                curve: Interval(0.2, 1.0, curve: Curves.easeOutBack)));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.only(top: 60.0),
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Image.asset(
                'assets/icons/logo.png',
                height: size.height / 5,
              ),
              /*CachedNetworkImage(
                imageUrl: 'assets/icons/logo.png',
                imageBuilder: (context, imageProvider) => EntryHeaderImage(
                  imageProvider: imageProvider,
                ),
                placeholder: (context, url) => EntryHeaderImage(
                  imageProvider: AssetImage('assets/icons/logo.png'),
                ),
                errorWidget: (context, url, error) => EntryHeaderImage(
                  imageProvider: AssetImage('assets/icons/logo.png'),
                ),
              ),
              Stack(
                children: <Widget>[
                  FormBuilderImagePicker(
                    name: 'photo',
                    decoration:
                        const InputDecoration(labelText: 'Chose a photo'),
                    maxImages: 1,
                    onChanged: (image) {
                      /*if (image.isNotEmpty) {
                        expertInfoViewModel.profilePhoto =
                            image[0].path.toString();
                        setState(() {
                          nextEnabled = true;
                        });
                      }*/
                    },
                  ),
                  Positioned(
                    top: 300.0,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(100.0),
                              topLeft: Radius.circular(100.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF3C4858).withOpacity(.4),
                              offset: Offset(0.0, -8),
                              blurRadius: 6,
                            )
                          ]),
                    ),
                  ),
                ],
              ),*/
              Container(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 50.0),
                child: Form(
                  key: _addEntryFormKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 45),
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
              )
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkResponse(
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xFF3C4858).withOpacity(.5),
                                offset: Offset(1.0, 10.0),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: Icon(Icons.arrow_back, color: Color(0xFF3C4858)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
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

  void _setOptionsStatus(AnimationStatus status) {
    setState(() {
      _optionsIsOpen = status == AnimationStatus.forward ||
          status == AnimationStatus.completed;
    });
  }

  /*_handleAddEntry() async {
    final response = await Provider.of<EntryViewModel>(context, listen: false)
        .create(_formData);
    if (response) {
      Navigator.of(context).pushNamed(Home.routeName);
    }
  }*/
}

class EntryHeaderImage extends StatelessWidget {
  final ImageProvider imageProvider;

  const EntryHeaderImage({
    Key key,
    this.imageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: imageProvider,
      child: Container(
        height: 340.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
              colorFilter:
                  ColorFilter.mode(Color(0xFF3C4858), BlendMode.lighten),
              image: imageProvider,
              fit: BoxFit.cover),
        ),
      ),
    );
  }*/
}
