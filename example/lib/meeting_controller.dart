import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom/zoom_options.dart';
// import 'package:flutter_zoom/flutter_zoom_web.dart';
import 'package:get/get.dart';
import 'package:flutter_zoom/zoom_view.dart';
// import 'dart:html' as html;

class MeetingController extends GetxController {
// set force debug mode for pint()
  bool forceDebugMode = false;

// for view
  TextEditingController meetingIdController = TextEditingController();
  TextEditingController meetingPasswordController = TextEditingController();

//for feature
  late Timer timer;
  ZoomOptions zoomOptions = ZoomOptions(
    domain: "zoom.us",
    appKey: "4j5zxMjeTgGYLTgqH4dx4g", //API KEY FROM ZOOM -- SDK KEY
    appSecret:
        "F6vF4c8vOgQcs6ZbmeLAKzRvtwXOQitG", //API SECRET FROM ZOOM -- SDK SECRET
  );

// for value
  String userId = "";

  /// Username For Join Meeting & Host Email For Start Meeting
  String userPassword = "";

  /// Host Password For Start Meeting
  String displayName = "";

  /// Disable No Audio
  String zoomToken = "";

  /// Zoom token for SDK
  String zoomAccessToken =
      "eyJ0eXAiOiJKV1QiLCJzdiI6IjAwMDAwMSIsInptX3NrbSI6InptX28ybSIsImFsZyI6IkhTMjU2In0.eyJhdWQiOiJjbGllbnRzbSIsInVpZCI6InVNMnVYc01uUVJPOGJVZ1REbWVnWUEiLCJpc3MiOiJ3ZWIiLCJzayI6IjMyNDUxMTA3ODA5MzUyNTMzOTUiLCJzdHkiOjEwMCwid2NkIjoidXMwNSIsImNsdCI6MCwiZXhwIjoxNjgxMTg1MTA5LCJpYXQiOjE2ODExNzc5MDksImFpZCI6Ijdrdy03dGlYU1N1QU50QlZlZE1DSVEiLCJjaWQiOiIifQ.j7-5jweLqQCWF8aZaXiVdwunywzA5iFIyKU0V00N0fg";

  ///To Hide Meeting Invite Url
  @override
  void onReady() {
    super.onReady();
    // meetingIdController.text = "87256899611";
    // meetingPasswordController.text = "6LPm81";
    // userId = "hvlamdev@gmail.com";
    // displayName = "Van Lam";
  }

  /// Join meeting with meeting id

  joinMeeting(BuildContext context) {
    if (meetingIdController.text.isNotEmpty &&
        meetingPasswordController.text.isNotEmpty) {
      var meetingOptions = ZoomMeetingOptions(
        userId: userId,
        meetingId: meetingIdController.text,
        meetingPassword: meetingPasswordController.text,
        displayName: displayName,
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        disableTitlebar: "false",
        viewOptions: "true",
        noAudio: "false",
        noDisconnectAudio: "false",
        meetingViewOptions: ZoomMeetingOptions.NO_TEXT_PASSWORD +
            ZoomMeetingOptions.NO_TEXT_MEETING_ID +
            ZoomMeetingOptions.NO_BUTTON_PARTICIPANTS,
      );

      var zoom = ZoomView();

      zoom.initZoom(zoomOptions).then((results) {
        if (results[0] == 0) {
          zoom.onMeetingStatus().listen((status) {
            if (kDebugMode || forceDebugMode) {
              print(
                  "[Meeting Status Stream] : " + status[0] + " - " + status[1]);
            }
            if (_isMeetingEnded(status[0])) {
              if (kDebugMode || forceDebugMode) {
                print("[Meeting Status] :- Ended");
              }
              timer.cancel();
            }
          });
          if (kDebugMode || forceDebugMode) {
            print("listen on event channel");
          }
          zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
            timer = Timer.periodic(const Duration(seconds: 2), (timer) {
              zoom.meetingStatus(meetingOptions.meetingId!).then((status) {
                if (kDebugMode || forceDebugMode) {
                  print("[Meeting Status Polling] : " +
                      status[0] +
                      " - " +
                      status[1]);
                }
              });
            });
          });
        }
      }).catchError((error) {
        if (kDebugMode || forceDebugMode) {
          print("[Error Generated] : " + error.toString());
        }
      });
    } else {
      if (meetingIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Enter a valid meeting id to continue."),
        ));
      } else if (meetingPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Enter a meeting password to start."),
        ));
      }
    }
  }

  // joinMeetingWeb(BuildContext context) {
  //   ZoomOptions zoomOptions = ZoomOptions(
  //       domain: "zoom.us",
  //       appKey: "4j5zxMjeTgGYLTgqH4dx4g",
  //       appSecret:
  //           "F6vF4c8vOgQcs6ZbmeLAKzRvtwXOQitG", //API SECRET FROM ZOOM - Jwt API Secret
  //       language: "en-US", // Optional - For Web
  //       showMeetingHeader: true, // Optional - For Web
  //       disableInvite: false, // Optional - For Web
  //       disableCallOut: false, // Optional - For Web
  //       disableRecord: false, // Optional - For Web
  //       disableJoinAudio: false, // Optional - For Web
  //       audioPanelAlwaysOpen: false, // Optional - For Web
  //       isSupportAV: true, // Optional - For Web
  //       isSupportChat: true, // Optional - For Web
  //       isSupportQA: true, // Optional - For Web
  //       isSupportCC: true, // Optional - For Web
  //       isSupportPolling: true, // Optional - For Web
  //       isSupportBreakout: true, // Optional - For Web
  //       screenShare: true, // Optional - For Web
  //       rwcBackup: '', // Optional - For Web
  //       videoDrag: true, // Optional - For Web
  //       sharingMode: 'both', // Optional - For Web
  //       videoHeader: true, // Optional - For Web
  //       isLockBottom: true, // Optional - For Web
  //       isSupportNonverbal: true, // Optional - For Web
  //       isShowJoiningErrorDialog: true, // Optional - For Web
  //       disablePreview: false, // Optional - For Web
  //       disableCORP: true, // Optional - For Web
  //       inviteUrlFormat: '', // Optional - For Web
  //       disableVOIP: false, // Optional - For Web
  //       disableReport: false, // Optional - For Web
  //       meetingInfo: const [
  //         // Optional - For Web
  //         'topic',
  //         'host',
  //         'mn',
  //         'pwd',
  //         'telPwd',
  //         'invite',
  //         'participant',
  //         'dc',
  //         'enctype',
  //         'report'
  //       ]);
  //   var meetingOptions = ZoomMeetingOptions(
  //     // userId: 'username', //pass username for join meeting only --- Any name eg:- EVILRATT.
  //     userId: meetingIdController
  //         .text, //Personal meeting id for start meeting required
  //     userPassword: meetingPasswordController
  //         .text, //Personal meeting passcode for start meeting required
  //     //To get personal meeting id and passcode follow https://zoom.us/meeting#/ and novigate to Personal Room tab
  //   );

  //   var zoom = ZoomViewWeb();
  //   zoom.initZoom(zoomOptions).then((results) {
  //     if (results[0] == 0) {
  //       // var zr = html.window.document.getElementById("zmmtg-root");
  //       // html.querySelector('body')?.append(zr!);
  //       zoom.onMeetingStatus().listen((status) {
  //         print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
  //       });
  //       final signature = zoom.generateSignature(zoomOptions.appKey.toString(),
  //           zoomOptions.appSecret.toString(), meetingIdController.text, 0);
  //       meetingOptions.jwtAPIKey = zoomOptions.appKey.toString();
  //       meetingOptions.jwtSignature = signature;
  //       zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
  //         print("[Meeting Status Polling] : " "$joinMeetingResult");
  //       });
  //     }
  //   }).catchError((error) {
  //     print("[Error Generated] : " + error);
  //   });
  // }

  /// Start Meeting With Custom Meeting ID and ZAK token
  startMeetingNormal(BuildContext context) {
    var meetingOptions = ZoomMeetingOptions(
      userId: userId,
      displayName: displayName,
      meetingId: meetingIdController.text,
      disableDialIn: "false",
      disableDrive: "false",
      disableInvite: "false",
      disableShare: "false",
      disableTitlebar: "false",
      viewOptions: "false",
      noAudio: "false",
      noDisconnectAudio: "false",
      zoomAccessToken: zoomAccessToken,
    );

    var zoom = ZoomView();

    zoom.initZoom(zoomOptions).then((results) {
      if (results[0] == 0) {
        zoom.onMeetingStatus().listen((status) {
          if (kDebugMode || forceDebugMode) {
            print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
          }
          if (_isMeetingEnded(status[0])) {
            if (kDebugMode || forceDebugMode) {
              print("[Meeting Status] :- Ended");
            }
            timer.cancel();
          }
          if (status[0] == "MEETING_STATUS_INMEETING") {
            zoom.meetingDetails().then((meetingDetailsResult) {
              if (kDebugMode || forceDebugMode) {
                print("[MeetingDetailsResult] :- " +
                    meetingDetailsResult.toString());
              }
            });
          }
        });

        zoom.startMeetingNormal(meetingOptions).then((loginResult) {
          if (kDebugMode || forceDebugMode) {
            print("[LoginResult] :- " + loginResult.toString());
          }
          if (loginResult[0] == "SDK ERROR") {
            //SDK INIT FAILED
            if (kDebugMode || forceDebugMode) {
              print((loginResult[1]).toString());
            }
          } else if (loginResult[0] == "LOGIN ERROR") {
            //LOGIN FAILED - WITH ERROR CODES
            if (kDebugMode || forceDebugMode) {
              print((loginResult[1]).toString());
            }
          } else {
            //LOGIN SUCCESS & MEETING STARTED - WITH SUCCESS CODE 200
            if (kDebugMode || forceDebugMode) {
              print((loginResult[0]).toString());
            }
          }
        });
      }
    }).catchError((error) {
      if (kDebugMode || forceDebugMode) {
        print("[Error Generated] : " + error);
      }
    });
  }

  /// get [bool] meeting status is ended
  bool _isMeetingEnded(String status) {
    var result = false;

    if (Platform.isAndroid) {
      result = status == "MEETING_STATUS_DISCONNECTING" ||
          status == "MEETING_STATUS_FAILED";
    } else {
      result = status == "MEETING_STATUS_IDLE";
    }
    return result;
  }
}
