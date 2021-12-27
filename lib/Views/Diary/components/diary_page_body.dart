import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';

/// Body of the Diary Page.
///
/// It displays the [DiaryPage] title and the content. If it is a new diary page,
/// it is modifiable and the [TopBar] will contain the confirm button that save the page into the Firebase DB,
/// otherwise it shows the title and the content of the page with its date.
///
/// It contains also the 'heart' button for setting the diary page as favourite. If the page date is
/// today, there is another button in order to modify the fields.
class DiaryPageBody extends StatefulWidget {
  /// Body of the Diary Page.
  ///
  /// It displays the [DiaryPage] title and the content. If it is a new diary page,
  /// it is modifiable and the [TopBar] will contain the confirm button that save the page into the Firebase DB,
  /// otherwise it shows the title and the content of the page with its date.
  ///
  /// It contains also the 'heart' button for setting the diary page as favourite. If the page date is
  /// today, there is another button in order to modify the fields.
  const DiaryPageBody({Key? key}) : super(key: key);

  @override
  _DiaryPageBodyState createState() => _DiaryPageBodyState();
}

class _DiaryPageBodyState extends State<DiaryPageBody> {
  // View Models
  late DiaryViewModel diaryViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // Alerts
  late Alert errorAlert;
  late Alert successAlert;

  // Stream Subscribtion
  late StreamSubscription<bool> subscription;

  FocusNode titleFocusNode = FocusNode();

  @override
  void initState() {
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    // Create the alerts
    errorAlert = createErrorAlert();
    successAlert = createSuccessAlert();

    // Subscribe to on submitting form of the view model
    subscription = subscribeToOnSubmittingViewModel();

    // Add a back button interceptor for listening to the OS back button
    BackButtonInterceptor.add(backButtonInterceptor);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Add post frame callback for requesting the focus on the title text field
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (diaryViewModel.isEditing.value) {
        titleFocusNode.requestFocus();
      }
    });
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              text: DateFormat("dd MMM yyyy").format(diaryViewModel.currentDiaryPage.value!.dateTime),
              textSize: 16.sp,
              backIcon: Icons.close_rounded,
              onBack: diaryViewModel.resetCurrentDiaryPage,
              buttons: [
                if (!diaryViewModel.isEditing.value) ...[
                  if (Utils.isToday(diaryViewModel.currentDiaryPage.value!.dateTime)) ...[
                    // If it is the diary page of today and isEditing is false, show the button for modifing the page
                    InkWell(
                      child: InkResponse(
                        onTap: () {
                          diaryViewModel.isEditing.value = true;
                          setState(() {});
                        },
                        child: Container(padding: EdgeInsets.all(10), child: Icon(CupertinoIcons.pencil_ellipsis_rectangle, color: Colors.white)),
                      ),
                    ),
                  ],
                  // If isEditing is false, show the button for setting the page as favourite or not
                  InkWell(
                    child: InkResponse(
                      onTap: () {
                        diaryViewModel.currentDiaryPage.value!.favourite = !diaryViewModel.currentDiaryPage.value!.favourite;
                        diaryViewModel.setFavourite(diaryViewModel.currentDiaryPage.value!.favourite);
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: diaryViewModel.currentDiaryPage.value!.favourite
                            ? Icon(CupertinoIcons.heart_fill, color: Colors.white)
                            : Icon(CupertinoIcons.heart, color: Colors.white),
                      ),
                    ),
                  ),
                ] else ...[
                  // Otherwise, if isEditing is true, show the button for submitting the page if the button
                  // is enabled by the text controllers
                  InkWell(
                    child: StreamBuilder(
                      stream: diaryViewModel.diaryForm.isButtonEnabled,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.data ?? false || (diaryViewModel.currentDiaryPage.value?.id.isNotEmpty ?? true)) {
                          return InkResponse(
                            onTap: () {
                              if (diaryViewModel.currentDiaryPage.value?.id.isNotEmpty ?? false) {
                                diaryViewModel.updatePage();
                              } else {
                                diaryViewModel.submitPage();
                              }
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 13.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                children: [
                  // Diary Page Title
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    enabled: diaryViewModel.isEditing.value,
                    focusNode: titleFocusNode,
                    minLines: 1,
                    maxLines: 2,
                    controller: diaryViewModel.titleTextCtrl,
                    cursorColor: kPrimaryColor,
                    style: TextStyle(color: kPrimaryColor, fontSize: 20.sp, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "What's out topic of discussion?",
                      hintStyle: TextStyle(color: kPrimaryDarkColorTrasparent, fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  ),
                  Divider(color: kPrimaryDarkColorTrasparent, height: 5, thickness: 0.5),
                  // Diary Page Content
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(top: 16.0),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          enabled: diaryViewModel.isEditing.value,
                          controller: diaryViewModel.contentTextCtrl,
                          cursorColor: kPrimaryColor,
                          style: TextStyle(color: kPrimaryColor, fontSize: 15.5.sp),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration.collapsed(
                            hintText: "Tell me something about it...",
                            hintStyle: TextStyle(color: kPrimaryDarkColorTrasparent, fontSize: 15.5.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Listen to the [isPageAdded] stream in order to show the success or error alert
  /// to the user.
  StreamSubscription<bool> subscribeToOnSubmittingViewModel() {
    return diaryViewModel.isPageAdded.listen((isSuccessfulAdd) {
      if (isSuccessfulAdd) {
        successAlert.show();
      } else {
        errorAlert.show();
      }
    });
  }

  /// Create the [Alert] that inform the users that the submission of the [DiaryPage] was successful.
  Alert createSuccessAlert() {
    return Alert(
      closeIcon: null,
      context: context,
      title: "Page submitted!",
      type: AlertType.success,
      style: AlertStyle(
        animationDuration: Duration(milliseconds: 0),
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: kPrimaryColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            successAlert.dismiss();
          },
          color: Colors.transparent,
        )
      ],
    );
  }

  /// Create the [Alert] that inform the users that there was an error in submitting the [DiaryPage].
  Alert createErrorAlert() {
    return Alert(
      closeIcon: null,
      context: context,
      title: "AN ERROR OCCURED",
      type: AlertType.error,
      style: AlertStyle(
        animationDuration: Duration(milliseconds: 0),
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            errorAlert.dismiss();
          },
          color: kPrimaryColor,
        )
      ],
    );
  }

  /// Function called by the back button interceptor.
  ///
  /// It resets the current diary page and the controllers and then pops the page.
  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    diaryViewModel.resetCurrentDiaryPage();
    routerDelegate.pop();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    subscription.cancel();
    super.dispose();
  }
}
