import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/blocs/defor_monitor_bloc.dart';
import 'package:mobile_app/blocs/events/defor_monitor_event.dart';
import 'package:mobile_app/blocs/states/defor_monitor_state.dart';
import 'package:mobile_app/model/deformation_monitor_data.dart';
import 'package:mobile_app/model/error_package.dart';
import 'package:mobile_app/presentations/dialog/dialog.dart';
import 'package:mobile_app/Presentations/widgets/constant.dart';
import 'package:mobile_app/Presentations/widgets/widget.dart';
import 'package:mobile_app/presentations/screens/monitor-main-screen/models/deformations/operating_params_deformation.dart';
import 'package:signalr_core/signalr_core.dart';

class DeformationMonitorScreen extends StatefulWidget {
  @override
  _DeformationMonitorScreenState createState() =>
      new _DeformationMonitorScreenState();
}

class _DeformationMonitorScreenState extends State<DeformationMonitorScreen> {
  int buffer1 = 0;
  int buffer2 = 0;
  int count = 0;
  HubConnection hubConnection;
  String data1 = "null";
  String data2 = "null";
  String data3 = "null";
  String data4 = "null";
  String data5 = "null";
  String data21 = "null";
  String data22 = "null";
  String data23 = "null";
  String data24 = "null";
  String warningMessage = "";
  String warningTitle = "";
  Color modeColor = Colors.black26;
  int mode;
  bool cylinder1 = false;
  bool cylinder2 = false;
  bool cylinder3 = false;
  bool running = false;
  bool warning = false;
  @override
  void initState() {
    super.initState();
    try {
      hubConnection = HubConnectionBuilder()
          .withUrl(Constants.baseUrl + '/hub')
          .withAutomaticReconnect()
          .build();
      hubConnection.keepAliveIntervalInMilliseconds = 10000;
      hubConnection.serverTimeoutInMilliseconds = 10000;
      hubConnection.onclose((error) {
        // print(error);
        return error != null
            ? BlocProvider.of<DeforMonitorBloc>(context).add(
                DeforMonitorEventConnectFail(
                    errorPackage: ErrorPackage(
                        message: "Ng???t k???t n???i",
                        detail: "???? ng???t k???t n???i ?????n m??y ch???!")))
            : null;
      });
      hubConnection.on("MonitorEndurance", monitorEnduranceHandlers);
    } on TimeoutException {
      BlocProvider.of<DeforMonitorBloc>(context).add(
          DeforMonitorEventConnectFail(
              errorPackage: ErrorPackage(
                  message: "Kh??ng t??m th???y m??y ch???",
                  detail: "Vui l??ng ki???m tra ???????ng truy???n!")));
    } on SocketException {
      BlocProvider.of<DeforMonitorBloc>(context).add(
          DeforMonitorEventConnectFail(
              errorPackage: ErrorPackage(
                  message: "Kh??ng t??m th???y m??y ch???",
                  detail: "Vui l??ng ki???m tra ???????ng truy???n!")));
    } catch (e) {
      BlocProvider.of<DeforMonitorBloc>(context).add(
          DeforMonitorEventConnectFail(
              errorPackage:
                  ErrorPackage(message: "L???i x???y ra", detail: e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    LoadingDialog loadingDialog = LoadingDialog(buildContext: context);
    return WillPopScope(
      onWillPop: () async {
        AlertDialogTwoBtnCustomized alertDialogOneBtnCustomized =
            AlertDialogTwoBtnCustomized(
                context: context,
                title: "B???n c?? mu???n?",
                desc: "???ng d???ng s??? t??? ng???t k???t n???i v???i m??y ch???",
                textBtn1: "C??",
                textBtn2: "Quay l???i",
                onPressedBtn1: () {
                  Navigator.pop(context);
                });
        hubConnection.state == HubConnectionState.connected
            ? alertDialogOneBtnCustomized.show()
            : null;
        return true;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: "H??? 1"),
                Tab(text: "H??? 2"),
              ],
            ),
            backgroundColor: Constants.mainColor,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                AlertDialogTwoBtnCustomized alertDialogOneBtnCustomized =
                    AlertDialogTwoBtnCustomized(
                        context: context,
                        title: "B???n c?? mu???n?",
                        desc: "???ng d???ng s??? t??? ng???t k???t n???i v???i m??y ch???",
                        textBtn1: "C??",
                        textBtn2: "Quay l???i",
                        onPressedBtn1: () {
                          Navigator.pop(context);
                        });
                hubConnection.state == HubConnectionState.connected
                    ? alertDialogOneBtnCustomized.show()
                    : Navigator.pop(context);
              },
            ),
            title: Text("Gi??m s??t ki???m tra ????? bi???n d???ng"),
          ),
          body: BlocConsumer<DeforMonitorBloc, DeforMonitorState>(
            listener: (context, deforMonitorState) async {
              if (deforMonitorState is Defor12MonitorStateInit) {
                data1 = deforMonitorState.data;
                data2 = deforMonitorState.data;
                data3 = deforMonitorState.data;
                data4 = deforMonitorState.data;
                data5 = deforMonitorState.data;
                data21 = deforMonitorState.data;
                data22 = deforMonitorState.data;
                data23 = deforMonitorState.data;
                data24 = deforMonitorState.data;
                modeColor = Colors.black26;
                warning = false;
                running = false;
                cylinder1 = false;
                cylinder2 = false;
                cylinder3 = false;
              } else if (deforMonitorState
                  is DeforMonitorStateConnectSuccessful) {
                loadingDialog.dismiss();
              } else if (deforMonitorState is DeforMonitorStateDataUpdated) {
                if (count == 0) {
                  count += 1;
                  buffer1 = deforMonitorState.deforMonitorData.errorCode;
                } else if (count == 1) {
                  count = 0;
                  buffer2 = deforMonitorState.deforMonitorData.errorCode;
                }
                switch (deforMonitorState.deforMonitorData.errorCode) {
                  case 0:
                    break;
                  case 100:
                    warningMessage = "Ho??n th??nh ch????ng tr??nh";
                    warningTitle = "TH??NG B??O";
                    break;
                  case 500:
                    warningMessage =
                        "C??i ?????t l???c, th???i gian gi???, s??? l???n nh???n v?? sai s???";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 501:
                    warningMessage = "L???c c??i ?????t h??? 1 qu?? l???n (>2000)";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 502:
                    warningMessage = "L???c c??i ?????t h??? 2 qu?? l???n (>2000)";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 503:
                    warningMessage = "H??? th???ng ch??a s???n s??ng";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 504:
                    warningMessage = "L???i xi lanh 1 ch??a t???i v??? tr?? ?????t l???c";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 505:
                    warningMessage = "L???i xi lanh 1 ch??a v??? v??? tr?? ban ?????u";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 506:
                    warningMessage = "L???i xi lanh 2 ch??a t???i v??? tr?? ?????t l???c";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 507:
                    warningMessage = "L???i xi lanh 2 ch??a v??? v??? tr?? ban ?????u";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 508:
                    warningMessage = "L???i xi lanh 3 ch??a t???i v??? tr?? ?????t l???c";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 509:
                    warningMessage = "L???i xi lanh 3 ch??a v??? v??? tr?? ban ?????u";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 510:
                    warningMessage = "D???ng h??? th???ng kh???n c???p";
                    warningTitle = "L???I X???Y RA";
                    break;
                  case 600:
                    warningMessage = "Xi lanh 1 qu?? l???c";
                    warningTitle = "C???NH B??O";
                    break;
                  case 601:
                    warningMessage = "Xi lanh 2 qu?? l???c";
                    warningTitle = "C???NH B??O";
                    break;
                  case 602:
                    warningMessage = "Xi lanh 3 qu?? l???c";
                    warningTitle = "C???NH B??O";
                    break;
                  case 603:
                    warningMessage = "Xi lanh 1 kh??ng ????? l???c";
                    warningTitle = "C???NH B??O";
                    break;
                  case 604:
                    warningMessage = "Xi lanh 2 kh??ng ????? l???c";
                    warningTitle = "C???NH B??O";
                    break;
                  case 605:
                    warningMessage = "Xi lanh 3 kh??ng ????? l???c";
                    warningTitle = "C???NH B??O";
                    break;
                  default:
                    break;
                }
                if (deforMonitorState.deforMonitorData.errorCode != 0) {
                  if (buffer1 != buffer2) {
                    AlertDialogOneBtnCustomized(
                            context: context,
                            title: warningTitle,
                            desc: warningMessage,
                            textBtn: "OK")
                        .show();
                  }
                }
                data1 = deforMonitorState.deforMonitorData.forceCylinderSp12
                    .toString();
                data2 =
                    deforMonitorState.deforMonitorData.timeHoldSp12.toString();
                data3 =
                    deforMonitorState.deforMonitorData.noPressSp12.toString();
                data4 =
                    deforMonitorState.deforMonitorData.noPressPv1.toString();
                data5 =
                    deforMonitorState.deforMonitorData.noPressPv2.toString();
                data21 = deforMonitorState.deforMonitorData.forceCylinderSp3
                    .toString();
                data22 =
                    deforMonitorState.deforMonitorData.timeHoldSp3.toString();
                data23 =
                    deforMonitorState.deforMonitorData.noPressSp3.toString();
                data24 =
                    deforMonitorState.deforMonitorData.noPressPv3.toString();
                running = deforMonitorState.deforMonitorData.greenStatus;
                warning = deforMonitorState.deforMonitorData.redStatus;
                cylinder1 = deforMonitorState.deforMonitorData.seclect1;
                cylinder2 = deforMonitorState.deforMonitorData.seclect1;
                cylinder3 = deforMonitorState.deforMonitorData.seclect2;
                switch (deforMonitorState.deforMonitorData.modeStatus) {
                  case 0:
                    modeColor = Colors.brown[500];
                    break;
                  case 1:
                    modeColor = Colors.blue;
                    break;
                  case 2:
                    modeColor = Color(0xff02692e);
                    break;
                  default:
                    modeColor = Colors.black26;
                }
              } else if (deforMonitorState is DeforMonitorStateConnectFail) {
                print(hubConnection.state.toString());
                loadingDialog.dismiss();
                AlertDialogOneBtnCustomized(
                        context: context,
                        title: deforMonitorState.errorPackage.message,
                        desc: deforMonitorState.errorPackage.detail)
                    .show();
              } else if (deforMonitorState
                  is Defor12MonitorStateLoadingRequest) {
                loadingDialog.show();
              }
            },
            builder: (context, deforMonitorState) => TabBarView(
              children: <Widget>[
                SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'TH??NG S??? V???N H??NH',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.0128),
                          CustomizedButton(
                            fontSize: 25,
                            width: SizeConfig.screenWidth * 0.5121,
                            height: SizeConfig.screenHeight * 0.05121,
                            onPressed: () {
                              BlocProvider.of<DeforMonitorBloc>(context).add(
                                  DeforMonitorEventHubConnected(
                                      hubConnection: hubConnection));
                            },
                            text: "Truy xu???t",
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hubConnection.state ==
                                        HubConnectionState.connected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: hubConnection.state ==
                                        HubConnectionState.connected
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                hubConnection.state ==
                                        HubConnectionState.connected
                                    ? "???? k???t n???i"
                                    : "Ng???t k???t n???i",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: hubConnection.state ==
                                            HubConnectionState.connected
                                        ? Colors.green
                                        : Colors.red),
                              ),
                              SizedBox(width: 20),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            width: SizeConfig.screenWidth * 0.8962,
                            height: SizeConfig.screenHeight * 0.2561,
                            child: MonitorOperatingParamsDefor1(
                              text1: "L???c n??n c??i ?????t",
                              text2: "Th???i gian gi???",
                              text3: "S??? l???n c??i ?????t",
                              text4: "S??? l???n hi???n t???i",
                              data1: data1,
                              data2: data2,
                              data3: data3,
                              colorText1: cylinder1 ? Colors.green : null,
                              colorText2: cylinder2 ? Colors.green : null,
                              data4: data4, //xilanh 1
                              data5: data5, //xilanh 2
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.0256),
                          Text(
                            'B???NG GI??M S??T',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.0256),
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            width: SizeConfig.screenWidth * 0.8962,
                            height: SizeConfig.screenHeight * 0.2176,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: SizeConfig.screenHeight * 0.1024,
                                      height: SizeConfig.screenHeight * 0.1024,
                                      decoration: new BoxDecoration(
                                        color: modeColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      "CH??? ?????",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: SizeConfig.screenHeight * 0.1024,
                                      height: SizeConfig.screenHeight * 0.1024,
                                      decoration: new BoxDecoration(
                                        color: running
                                            ? Colors.green
                                            : Colors.black26,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      "??ANG CH???Y",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: SizeConfig.screenHeight * 0.1024,
                                      height: SizeConfig.screenHeight * 0.1024,
                                      decoration: new BoxDecoration(
                                        color: warning
                                            ? Colors.red
                                            : Colors.black26,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      "C???NH B??O",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              "B???ng ch?? th??ch m?? m??u",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration:
                                        BoxDecoration(color: Colors.brown[500]),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "T???m d???ng",
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(width: 15),
                                ClipOval(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration:
                                        BoxDecoration(color: Colors.blue),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Th??? c??ng",
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(width: 15),
                                ClipOval(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration:
                                        BoxDecoration(color: Color(0xff02692e)),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "T??? ?????ng",
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'TH??NG S??? V???N H??NH',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.0128),
                          CustomizedButton(
                            fontSize: 25,
                            width: SizeConfig.screenWidth * 0.5121,
                            height: SizeConfig.screenHeight * 0.05121,
                            onPressed: () {
                              BlocProvider.of<DeforMonitorBloc>(context).add(
                                  DeforMonitorEventHubConnected(
                                      hubConnection: hubConnection));
                            },
                            text: "Truy xu???t",
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hubConnection.state ==
                                        HubConnectionState.connected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: hubConnection.state ==
                                        HubConnectionState.connected
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                hubConnection.state ==
                                        HubConnectionState.connected
                                    ? "???? k???t n???i"
                                    : "Ng???t k???t n???i",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: hubConnection.state ==
                                            HubConnectionState.connected
                                        ? Colors.green
                                        : Colors.red),
                              ),
                              SizedBox(width: 20),
                            ],
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.0128),
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            width: SizeConfig.screenWidth * 0.8962,
                            height: SizeConfig.screenHeight * 0.2561,
                            child: MonitorOperatingParamsDefor(
                              text1: "L???c n??n c??i ?????t",
                              text2: "Th???i gian gi???",
                              text3: "S??? l???n c??i ?????t",
                              text4: "S??? l???n hi???n t???i",
                              data1: data21,
                              data2: data22,
                              data3: data23,
                              data4: data24,
                              colorText1: cylinder3 ? Colors.green : null,
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.0256),
                          Text(
                            'B???NG GI??M S??T',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.0256),
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            width: SizeConfig.screenWidth * 0.8962,
                            height: SizeConfig.screenHeight * 0.2176,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: SizeConfig.screenHeight * 0.1024,
                                      height: SizeConfig.screenHeight * 0.1024,
                                      decoration: new BoxDecoration(
                                        color: modeColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      "CH??? ?????",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: SizeConfig.screenHeight * 0.1024,
                                      height: SizeConfig.screenHeight * 0.1024,
                                      decoration: new BoxDecoration(
                                        color: running
                                            ? Colors.green
                                            : Colors.black26,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      "??ANG CH???Y",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: SizeConfig.screenHeight * 0.1024,
                                      height: SizeConfig.screenHeight * 0.1024,
                                      decoration: new BoxDecoration(
                                        color: warning
                                            ? Colors.red
                                            : Colors.black26,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      "C???NH B??O",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              "B???ng ch?? th??ch m?? m??u",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration:
                                        BoxDecoration(color: Colors.brown[500]),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "T???m d???ng",
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(width: 15),
                                ClipOval(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration:
                                        BoxDecoration(color: Colors.blue),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Th??? c??ng",
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(width: 15),
                                ClipOval(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration:
                                        BoxDecoration(color: Color(0xff02692e)),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "T??? ?????ng",
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
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
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  void monitorEnduranceHandlers(List<dynamic> data) {
    BlocProvider.of<DeforMonitorBloc>(context).add(DeforMonitorEventDataUpdated(
        deforMonitorData: DeforMonitorData(
      noPressPv1: Map<String, dynamic>.from(data[0])["numberOfTestPv1"],
      noPressPv2: Map<String, dynamic>.from(data[0])["numberOfTestPv2"],
      noPressPv3: Map<String, dynamic>.from(data[0])["numberOfTestPv3"],
      noPressSp12: Map<String, dynamic>.from(data[0])["numberOfTestSp12"],
      noPressSp3: Map<String, dynamic>.from(data[0])["numberOfTestSp3"],
      errorCode: Map<String, dynamic>.from(data[0])["errorCode"],
      modeStatus: Map<String, dynamic>.from(data[0])["modeStatus"],
      forceCylinderSp12:
          Map<String, dynamic>.from(data[0])["forceCylinderSp12"].toString(),
      forceCylinderSp3:
          Map<String, dynamic>.from(data[0])["forceCylinderSp3"].toString(),
      timeHoldSp12:
          Map<String, dynamic>.from(data[0])["timeHoldSp12"].toString(),
      timeHoldSp3: Map<String, dynamic>.from(data[0])["timeHoldSp3"].toString(),
      seclect1: Map<String, dynamic>.from(data[0])["seclect1"],
      seclect2: Map<String, dynamic>.from(data[0])["seclect2"],
      redStatus: Map<String, dynamic>.from(data[0])["redStatus"],
      errorStatus: Map<String, dynamic>.from(data[0])["errorStatus"],
      greenStatus: Map<String, dynamic>.from(data[0])["greenStatus"],
    )));
  }
}
