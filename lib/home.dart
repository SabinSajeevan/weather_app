import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Position _currentPosition;
  String place = '';
  String date = '';
  String weather = '';
  String des = '', humidity = '', wind_speed = '';
  bool isLoading = true;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      print(place.locality);
      getWeather(place.locality);
    } catch (e) {
      print(e);
    }
  }

  getWeather(String locality) async {
    var client = http.Client();
    try {
      var queryParameters = {
        'access_key': 'e13c1928cae178a12c6a788c358b0284',
        'query': locality,
      };
      var uri = Uri.http('api.weatherstack.com', '/current', queryParameters);
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          place = jsonDecode(response.body)['location']['name'];
          date = jsonDecode(response.body)['location']['localtime'];
          weather =
              jsonDecode(response.body)['current']['temperature'].toString();
          des =
              (jsonDecode(response.body)['current']['weather_descriptions'])[0];
          humidity =
              jsonDecode(response.body)['current']['humidity'].toString();
          wind_speed =
              jsonDecode(response.body)['current']['wind_speed'].toString();
          isLoading = false;
          _scaffoldKey.currentState
              .showSnackBar(new SnackBar(content: new Text("Updated!..")));
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(
            new SnackBar(content: new Text("Error fetching data")));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _scaffoldKey.currentState
          .showSnackBar(new SnackBar(content: new Text("Error fetching data")));
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/background.jpg"),
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.9), BlendMode.dstATop),
            ),
          ),
          child: isLoading && place == ''
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : place == ''
                  ? Center(
                      child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                              customBorder: CircleBorder(),
                              onTap: () {
                                setState(() {
                                  isLoading = true;
                                });
                                _getCurrentLocation();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ))),
                    )
                  : Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 80,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        place,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 45),
                                      ),
                                      Text(
                                        DateFormat.yMMMd()
                                            .format(DateTime.parse(date)),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )),
                                  isLoading
                                      ? CircularProgressIndicator()
                                      : Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                              customBorder: CircleBorder(),
                                              onTap: () {
                                                _scaffoldKey.currentState
                                                    .showSnackBar(new SnackBar(
                                                        content: new Text(
                                                            "Fetching data")));
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                _getCurrentLocation();
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Icon(
                                                  Icons.refresh,
                                                  color: Colors.white,
                                                  size: 35,
                                                ),
                                              )))
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    weather,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 100),
                                  ),
                                  Text(
                                    weather != '' ? "℃" : '',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 50),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  des != ''
                                      ? Image.asset(
                                          "images/logo.png",
                                          width: 50,
                                          color: Colors.white,
                                        )
                                      : Container(),
                                  Text(
                                    des,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Divider(
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  humidity == ''
                                      ? Container()
                                      : Column(
                                          children: <Widget>[
                                            Text(
                                              "Humidity",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "$humidity%",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        ),
                                  wind_speed == ''
                                      ? Container()
                                      : Column(
                                          children: <Widget>[
                                            Text(
                                              "Wind Speed",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "$wind_speed km/h",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
