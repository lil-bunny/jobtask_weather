import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../model/wearhermodel.dart';

class WeatherController extends GetxController {
  var feelslike = ''.obs;
  var currentTemp = ''.obs;
  var currentTempType = ''.obs;
  var currentLat = 0.0.obs;
  var currentLong = 0.0.obs;
  var seachText = TextEditingController();
  var hasGotTemp = false.obs;
  var windspeed = ''.obs;
  var pressure = ''.obs;
  var rainchance = ''.obs;
  var weatherList = <WeatherModel>[].obs;
  var humidity = ''.obs;
  var currentCity = ''.obs;
  var currentCountry = ''.obs;
  var currentDatetime = ''.obs;
  var isLoading = true.obs;
  var tempicon = 'http://openweathermap.org/img/wn/03d.png'.obs;
  void setIcon(String code) {
    tempicon.value = 'http://openweathermap.org/img/wn/${code}.png';
  }

  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  String formatTimestamp(int timestamp) {
    // Convert Unix timestamp to DateTime object
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    // Set up formatter for the desired format
    DateFormat formatter = DateFormat('MMMM dd, hh:mm a');

    // Format the DateTime object to a string
    String formattedDate = formatter.format(date);

    return formattedDate;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void getWeatherList() async {
    try {
      isLoading.value = true;
      var url =
          "https://open-weather13.p.rapidapi.com/city/fivedaysforcast/${currentLat.value}/${currentLong.value}";
      var result = await Dio()
          .get(
            url,
            options: Options(
              headers: {
                'x-rapidapi-host': 'open-weather13.p.rapidapi.com',
                'x-rapidapi-key':
                    'e3a67ee396msh43de1bea29c92cfp16fd16jsn58860d4e1c48',
              },
            ),
          )
          .then((value) => value.data);
      print("list=${result['list'].length}");
      var list = result['list'] as List<dynamic>;
      if (result['list'].length > 0) {
        weatherList.value = list.map((e) => WeatherModel.fromJson(e)).toList();
        print("result=${weatherList.value}");
      }
      isLoading.value = false;
    } catch (e) {
      print("Free api limit exceeded");
    }
  }

  var imgindex = 0;
  int getRandomNumber() {
    Random random = Random();
    return random
        .nextInt(4); // Generates a random integer from 0 to 3 (inclusive)
  }

  var imagelist = [
    'https://as1.ftcdn.net/v2/jpg/06/11/36/86/1000_F_611368636_pCiOdyEG9IWjS6nFNmSFFbtPYAV0T8aa.jpg',
    'https://as1.ftcdn.net/v2/jpg/05/71/37/20/1000_F_571372005_sxVuN1xYxb8uTtAcaKB0p3msx4PQRsjc.jpg',
    'https://static.vecteezy.com/system/resources/previews/030/600/892/large_2x/japanese-cartoon-character-looking-at-the-city-at-night-ai-generative-free-photo.jpg',
    'https://static.vecteezy.com/system/resources/previews/026/945/309/non_2x/illustration-cafe-on-the-street-night-made-with-generative-ai-photo.jpg'
  ];
  void getWeatherDetailsbylatlong(Position pos) async {
    try {
      isLoading.value = true;
      var url =
          "https://open-weather13.p.rapidapi.com/city/latlon/${pos.latitude}/${pos.longitude}";

      Map<String, dynamic> result = await Dio()
          .get(
            url,
            options: Options(
              headers: {
                'x-rapidapi-host': 'open-weather13.p.rapidapi.com',
                'x-rapidapi-key':
                    'e3a67ee396msh43de1bea29c92cfp16fd16jsn58860d4e1c48',
              },
            ),
          )
          .then((value) => value.data);
      print(result);
      var res = WeatherModel.fromJson(result);
      feelslike.value =
          "${(kelvinToCelsius(res.main.feelsLike)).toStringAsFixed(0)}";
      currentTemp.value =
          "${(kelvinToCelsius(res.main.temp)).toStringAsFixed(0)}";
      windspeed.value = res.wind.speed.toString();
      setIcon(res.weather[0].icon);
      currentTempType.value = res.weather[0].description;
      hasGotTemp.value = true;
      humidity.value = res.main.humidity.toString();
      pressure.value = res.main.pressure.toString();
      currentCity.value = res.name;

      currentDatetime.value = formatTimestamp(res.dt);
      currentCountry.value = res.sys.country;
      isLoading.value = false;
    } catch (e) {
      print("error api limit exceeded");
    }
  }

  void getWeatherDetails(String city) async {
    getRandomNumber();
    try {
      var url = "https://open-weather13.p.rapidapi.com/city/${city}/EN";
      print("api called =${url}");
      Map<String, dynamic> result = await Dio()
          .get(
            url,
            options: Options(
              headers: {
                'x-rapidapi-host': 'open-weather13.p.rapidapi.com',
                'x-rapidapi-key':
                    'e3a67ee396msh43de1bea29c92cfp16fd16jsn58860d4e1c48',
              },
            ),
          )
          .then((value) => value.data);
      print(result);
      var res = WeatherModel.fromJson(result);
      feelslike.value =
          "${((res.main.feelsLike - 32) * 5 / 9).toStringAsFixed(0)}";
      currentTemp.value =
          "${((res.main.temp - 32) * 5 / 9).toStringAsFixed(0)}";
      windspeed.value = res.wind.speed.toString();
      currentTempType.value = res.weather[0].description;
      hasGotTemp.value = true;
      setIcon(res.weather[0].icon);
      humidity.value = res.main.humidity.toString();
      pressure.value = res.main.pressure.toString();
      currentCity.value = res.name;
      currentDatetime.value = formatTimestamp(res.dt);
      currentCountry.value = res.sys.country;
      isLoading.value = false;
    } catch (e) {
      print("api limit exceeded");
    }
  }

  @override
  void onInit() async {
    await _determinePosition().then((value) {
      currentLat.value = value.latitude;
      currentLong.value = value.longitude;
      print("lat long=${currentLat} ${currentLong}");
      getWeatherDetailsbylatlong(value);
      // getWeatherDetails('Kolkata');
      getWeatherList();
    });

    super.onInit();
  }
}
