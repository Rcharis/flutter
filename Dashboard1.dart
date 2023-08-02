import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stb_01/CircleProgress.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  late AnimationController progressController;
  late Animation<double> tempAnimation;
  late Animation<double> humidityAnimation;

  double? temp;
  double? humidity;

  Future<Map<String, dynamic>> fetchData() async {
    final databaseReference = FirebaseDatabase.instance.reference();

    // Use the `once()` method to get the DatabaseEvent
    DatabaseEvent snapshot = await databaseReference
        .child('sensor_proximity_suhu_kelembaban')
        .once();

    // Handle the possibility of a null value
    if (snapshot.snapshot.value == null) {
      return {};
    }

    Map<dynamic, dynamic>? dynamicData = snapshot.snapshot.value as Map<dynamic, dynamic>?;
    if (dynamicData != null) {
      // Access the elements of dynamicData safely here
    } else {
      // Handle the case when dynamicData is null
    }

    Map<String, dynamic> data = _convertDynamicMapToMap(dynamicData!);
    return data;
  }

  Map<String, dynamic> _convertDynamicMapToMap(Map<dynamic, dynamic> dynamicMap) {
    Map<String, dynamic> resultMap = {};
    dynamicMap.forEach((key, value) {
      resultMap[key.toString()] = value;
    });
    return resultMap;
  }

  @override
  void initState() {
    super.initState();

    fetchData().then((data) {
      if (data.containsKey('sensor_Suhu') && data['sensor_Suhu'] != null &&
          data['sensor_Suhu'].containsKey('sensor_T')) {
        temp = data['sensor_Suhu']['sensor_T'];
        // Do something with 'temp'
      }

      if (data.containsKey('sensor_Kelembaban') && data['sensor_Kelembaban'] != null &&
          data['sensor_Kelembaban'].containsKey('Sensor_H')) {
        humidity = data['sensor_Kelembaban']['Sensor_H'];
        // Do something with 'sensor_Kelembaban'
      }

      if (temp != null && humidity != null) {
        isLoading = true;
        _dashboardInit(temp!, humidity!);
      } else {
        // Handle the case when temp or humidity is null
        // You can show an error message or perform any other appropriate action.
      }
    });
  }


  _dashboardInit(double temp, double humidity) {
    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 5000)); //5s

    tempAnimation = Tween<double>(begin: -50, end: temp).animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    humidityAnimation = Tween<double>(begin: -50, end: humidity).animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: Icon(Icons.reorder),
          onPressed: () {},
        ),
      ),
      body: Center(
        child: isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CustomPaint(
              foregroundPainter: CircleProgress(tempAnimation.value, true),
              child: Container(
                width: 200,
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Temperature'),
                      Text(
                        '${tempAnimation.value.toInt()}',
                        style: TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '°C',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
            : Text(
          'Loading',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
