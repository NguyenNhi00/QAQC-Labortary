import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/presentations/screens/monitor-main-screen/models/reliabilities/operating_params_reliability.dart';
import 'package:mobile_app/presentations/widgets/constant.dart';
import 'package:mobile_app/presentations/widgets/widget.dart';
import 'package:mobile_app/blocs/blocs/reli_monitor_bloc.dart';
import 'package:mobile_app/blocs/events/reli_monitor_event.dart';
import 'package:mobile_app/blocs/states/reli_monitor_state.dart';
import 'package:mobile_app/model/error_package.dart';
import 'package:mobile_app/model/reliability_cb_monitor_data.dart';
import 'package:mobile_app/model/reliability_monitor_data.dart';
import 'package:mobile_app/presentations/dialog/dialog.dart';
import 'package:signalr_core/signalr_core.dart';

class ReliabilityMonitorScreen extends StatefulWidget {
  ReliabilityMonitorScreen({Key key}) : super(key: key);
  @override
  _ReliabilityMonitorScreenState createState() =>
      new _ReliabilityMonitorScreenState();
}

class _ReliabilityMonitorScreenState extends State<ReliabilityMonitorScreen> {
  String data1 = "null";
  String data2 = "null";
  String data3 = "null";
  String data4 = "null";
  String data21 = "null";
  String data22 = "null";
  String data23 = "null";
  String data24 = "null";
  bool warning = false;
  bool running = false;
  bool warning2 = false;
  bool running2 = false;
  HubConnection hubConnection;
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
        return error != null
            ? BlocProvider.of<ReliMonitorBloc>(context).add(
                ReliMonitorEventConnectFail(
                    errorPackage: ErrorPackage(
                        message: "Ng???t k???t n???i",
                        detail: "???? ng???t k???t n???i ?????n m??y ch???!")))
            : null;
      });
      hubConnection.on("MonitorReliability", monitorReliabilityHandlers);
      hubConnection.on("MonitorDeformation", monitorDeformationHandlers);
    } on TimeoutException {
      BlocProvider.of<ReliMonitorBloc>(context).add(ReliMonitorEventConnectFail(
          errorPackage: ErrorPackage(
              message: "Kh??ng t??m th???y m??y ch???",
              detail: "Vui l??ng ki???m tra ???????ng truy???n!")));
    } on SocketException {
      BlocProvider.of<ReliMonitorBloc>(context).add(ReliMonitorEventConnectFail(
          errorPackage: ErrorPackage(
              message: "Kh??ng t??m th???y m??y ch???",
              detail: "Vui l??ng ki???m tra ???????ng truy???n!")));
    } catch (e) {
      BlocProvider.of<ReliMonitorBloc>(context).add(ReliMonitorEventConnectFail(
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
                Tab(text: "????? b???n ??m"),
                Tab(text: "????? b???n CB"),
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
            title: Text("Gi??m s??t ki???m tra ????? b???n"),
          ),
          backgroundColor: Colors.white,
          body: BlocConsumer<ReliMonitorBloc, ReliMonitorState>(
            listener: (context, reliMonitorState) async {
              if (reliMonitorState is ReliMonitorStateConnectFail) {
                loadingDialog.dismiss();
                AlertDialogOneBtnCustomized(
                        context: context,
                        title: reliMonitorState.errorPackage.message,
                        desc: reliMonitorState.errorPackage.detail,
                        textBtn: "OK",
                        closePressed: () {},
                        onPressedBtn: () {})
                    .show();
              } else if (reliMonitorState is ReliMonitorStateConnectSucessful) {
                loadingDialog.dismiss();
                data1 = reliMonitorState.reliMonitorData.soLanDongNapCaiDat
                    .toString();
                data2 = reliMonitorState.reliMonitorData.soLanDongNapHienTai
                    .toString();
                data3 = reliMonitorState.reliMonitorData.thoiGianGiuNapDong
                    .toString();
                data4 = reliMonitorState.reliMonitorData.thoiGianGiuNapMo
                    .toString();
                warning = reliMonitorState.reliMonitorData.alarm;
                running = reliMonitorState.reliMonitorData.running;

                // print(hubConnection.state.toString());
              } else if (reliMonitorState is ReliMonitorStateDataUpdated) {
                loadingDialog.dismiss();
                // print('ch???p ???????c state n??');
                data1 = reliMonitorState.reliMonitorData.soLanDongNapCaiDat
                    .toString();
                data2 = reliMonitorState.reliMonitorData.soLanDongNapHienTai
                    .toString();
                data3 = reliMonitorState.reliMonitorData.thoiGianGiuNapDong
                    .toString();
                data4 = reliMonitorState.reliMonitorData.thoiGianGiuNapMo
                    .toString();
                warning = reliMonitorState.reliMonitorData.alarm;
                running = reliMonitorState.reliMonitorData.running;
              } else if (reliMonitorState is ReliMonitorStateLoadingRequest) {
                loadingDialog.show();
              } else if (reliMonitorState is ReliCBMonitorStateLoadingRequest) {
                loadingDialog.show();
              }
              if (reliMonitorState is ReliCBMonitorStateConnectFail) {
                loadingDialog.dismiss();
                AlertDialogOneBtnCustomized(
                        context: context,
                        title: reliMonitorState.errorPackage.message,
                        desc: reliMonitorState.errorPackage.detail,
                        textBtn: "OK",
                        closePressed: () {},
                        onPressedBtn: () {})
                    .show();
              } else if (reliMonitorState
                  is ReliCBMonitorStateConnectSucessful) {
                loadingDialog.dismiss();
                data21 = reliMonitorState.reliCBMonitorData.soLanDongNapCaiDat
                    .toString();
                data22 = reliMonitorState.reliCBMonitorData.soLanDongNapHienTai
                    .toString();
                data23 = reliMonitorState.reliCBMonitorData.thoiGianGiuNapDong
                    .toString();
                data24 = reliMonitorState.reliCBMonitorData.thoiGianGiuNapMo
                    .toString();
                warning2 = reliMonitorState.reliCBMonitorData.alarm;
                running2 = reliMonitorState.reliCBMonitorData.running;
                // print(hubConnection.state.toString());
              } else if (reliMonitorState is ReliCBMonitorStateDataUpdated) {
                loadingDialog.dismiss();
                // print('ch???p ???????c state n??');
                data21 = reliMonitorState.reliCBMonitorData.soLanDongNapCaiDat
                    .toString();
                data22 = reliMonitorState.reliCBMonitorData.soLanDongNapHienTai
                    .toString();
                data23 = reliMonitorState.reliCBMonitorData.thoiGianGiuNapDong
                    .toString();
                data24 = reliMonitorState.reliCBMonitorData.thoiGianGiuNapMo
                    .toString();
                warning2 = reliMonitorState.reliCBMonitorData.alarm;
                running2 = reliMonitorState.reliCBMonitorData.running;
              }
            },
            builder: (context, reliMonitorState) => WillPopScope(
              onWillPop: () async {
                return hubConnection.state == HubConnectionState.connected
                    ? false
                    : true;
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabBarView(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 30),
                            Text(
                              'TH??NG S??? V???N H??NH',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: SizeConfig.screenHeight * 0.0128),
                            CustomizedButton(
                              fontSize: 25,
                              width: SizeConfig.screenWidth * 0.5121,
                              height: SizeConfig.screenHeight * 0.05121,
                              onPressed: () {
                                // BlocProvider.of<ReliMonitorBloc>(context)
                                //     .add(ReliMonitorEventSearchingClicked());
                                BlocProvider.of<ReliMonitorBloc>(context).add(
                                    ReliMonitorEventHubConnected(
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
                              child: MonitorOperatingParamsReli(
                                  text1: "S??? l???n ????ng n???p c??i ?????t",
                                  text2: "S??? l???n ????ng n???p hi???n t???i",
                                  text3: "Th???i gian ????ng n???p c???u",
                                  text4: "Th???i gian m??? n???p c???u",
                                  data1: data1,
                                  data2: data2,
                                  data3: data3,
                                  data4: data4),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: SizeConfig.screenHeight * 0.1280,
                                        height:
                                            SizeConfig.screenHeight * 0.1280,
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
                                        width: SizeConfig.screenHeight * 0.1280,
                                        height:
                                            SizeConfig.screenHeight * 0.1280,
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
                              padding: const EdgeInsets.all(8.0),
                              child: Visibility(
                                visible:
                                    warning && data1 == data2 ? true : false,
                                child: Text(
                                  '???? ho??n th??nh ch????ng tr??nh!',
                                  style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Visibility(
                                visible:
                                    warning && data1 != data2 ? true : false,
                                child: Text(
                                  'H??? th???ng x???y ra l???i!',
                                  style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: SizeConfig.screenHeight * 0.03841),
                            Text(
                              'TH??NG S??? V???N H??NH',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: SizeConfig.screenHeight * 0.0128),
                            CustomizedButton(
                              fontSize: 25,
                              width: SizeConfig.screenWidth * 0.5121,
                              height: SizeConfig.screenHeight * 0.05121,
                              onPressed: () {
                                BlocProvider.of<ReliMonitorBloc>(context).add(
                                    ReliCBMonitorEventHubConnected(
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
                              child: MonitorOperatingParamsReli(
                                  text1: "S??? l???n ????ng n???p c??i ?????t",
                                  text2: "S??? l???n ????ng n???p hi???n t???i",
                                  text3: "Th???i gian d???ng xu???ng",
                                  text4: "Th???i gian d???ng l??n",
                                  data1: data21,
                                  data2: data22,
                                  data3: data23,
                                  data4: data24),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: SizeConfig.screenHeight * 0.1280,
                                        height:
                                            SizeConfig.screenHeight * 0.1280,
                                        decoration: new BoxDecoration(
                                          color: running2
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
                                        width: SizeConfig.screenHeight * 0.1280,
                                        height:
                                            SizeConfig.screenHeight * 0.1280,
                                        decoration: new BoxDecoration(
                                          color: warning2
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
                              padding: const EdgeInsets.all(8.0),
                              child: Visibility(
                                visible:
                                    warning2 && data21 == data22 ? true : false,
                                child: Text(
                                  '???? ho??n th??nh ch????ng tr??nh!',
                                  style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Visibility(
                                visible:
                                    warning2 && data21 != data22 ? true : false,
                                child: Text(
                                  'H??? th???ng x???y ra l???i!',
                                  style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void monitorReliabilityHandlers(List<dynamic> data) {
    print(Map<String, dynamic>.from(data[0])["alarm"]);
    BlocProvider.of<ReliMonitorBloc>(context).add(ReliMonitorEventDataUpdated(
        reliMonitorData: ReliMonitorData(
            alarm: Map<String, dynamic>.from(data[0])["alarm"],
            running: Map<String, dynamic>.from(data[0])["running"],
            thoiGianGiuNapDong:
                Map<String, dynamic>.from(data[0])["timeLidClose"],
            thoiGianGiuNapMo: Map<String, dynamic>.from(data[0])["timeLidOpen"],
            soLanDongNapCaiDat:
                Map<String, dynamic>.from(data[0])["numberClosingSp"],
            soLanDongNapHienTai:
                Map<String, dynamic>.from(data[0])["numberClosingPv"])));
  }

  void monitorDeformationHandlers(List<dynamic> data) {
    // print('H???ng d??? li???u');
    // print(Map<String, dynamic>.from(data[0])["alarm"]);
    BlocProvider.of<ReliMonitorBloc>(context).add(ReliCBMonitorEventDataUpdated(
        reliCBMonitorData: ReliCBMonitorData(
            alarm: Map<String, dynamic>.from(data[0])["alarm"],
            running: Map<String, dynamic>.from(data[0])["running"],
            thoiGianGiuNapDong:
                Map<String, dynamic>.from(data[0])["timeLidClose"],
            thoiGianGiuNapMo: Map<String, dynamic>.from(data[0])["timeLidOpen"],
            soLanDongNapCaiDat:
                Map<String, dynamic>.from(data[0])["numberClosingSp"],
            soLanDongNapHienTai:
                Map<String, dynamic>.from(data[0])["numberClosingPv"])));
  }
}
