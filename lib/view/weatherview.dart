import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobtask/controller/weathercontroller.dart';

import 'package:geolocator/geolocator.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var controller = Get.put(WeatherController());

    Widget tempCard(icon, title, subtitle) {
      return Container(
        height: height * 0.1,
        width: width * 0.45,
        child: ListTile(
            leading: CircleAvatar(
                backgroundImage: NetworkImage(icon),
                backgroundColor: Colors.transparent),
            title: Text(title),
            subtitle: Text(subtitle)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      );
    }

    var forecastList = [
      tempCard(
          'https://firebasestorage.googleapis.com/v0/b/trydripai.appspot.com/o/Wind%20Speed.png?alt=media&token=849d4e88-f338-4fb4-bb5c-e09ac13ed547',
          'Wind speed',
          '${controller.windspeed.value} km/h'),
      tempCard('https://cdn-icons-png.flaticon.com/512/4148/4148460.png',
          'Humidity', '${controller.humidity.value}%'),
      tempCard('https://cdn-icons-png.freepik.com/512/62/62848.png', 'Pressure',
          '${controller.pressure.value} hpa '),
    ];
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 246, 246),
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Fetching the weather details'),
                    SizedBox(
                      width: 10,
                    ),
                    CircularProgressIndicator(
                      color: Colors.deepPurple,
                    )
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  controller.hasGotTemp.value == ''
                      ? Container()
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                Container(
                                  height: height * 0.4,
                                  width: width,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(
                                                0.5), // Adjust opacity as needed
                                            BlendMode.dstATop,
                                          ),
                                          image: CachedNetworkImageProvider(
                                              controller.imagelist[controller
                                                  .getRandomNumber()])),
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(30),
                                          bottomRight: Radius.circular(30))),
                                ),
                                Positioned(
                                  bottom: height * 0.1,
                                  child: Container(
                                    width: width,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    width: width * 0.5,
                                                    height: height * 0.1,
                                                    child: Text(
                                                      '${controller.currentTemp.value}\u00B0',
                                                      style: TextStyle(
                                                          fontSize: 60,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 2,
                                                  right: 18,
                                                  child: Text(
                                                    'Feels like ${controller.feelslike.value}\u00B0',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: height * 0.1,
                                                  child: CachedNetworkImage(
                                                    imageUrl: controller
                                                        .tempicon.value,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Container(
                                                  width: width * 0.3,
                                                  child: Text(
                                                    controller
                                                        .currentTempType.value,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 20,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        controller.currentDatetime.value,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ))
                              ],
                            ),
                            Positioned(
                              top: kToolbarHeight,
                              child: Container(
                                width: width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${controller.currentCity.value}, ${controller.currentCountry.value}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) => Scaffold(
                                            appBar: AppBar(),
                                            body: Container(
                                              height: height,
                                              width: width,
                                              child: TextField(
                                                  controller:
                                                      controller.seachText,
                                                  decoration: InputDecoration(
                                                      suffix: IconButton(
                                                          onPressed: () {
                                                            if (controller
                                                                .seachText
                                                                .text
                                                                .isEmpty) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Container(
                                                                child: Text(
                                                                    'You must enter the city name'),
                                                              )));
                                                              return;
                                                            }
                                                            controller
                                                                    .currentCity
                                                                    .value =
                                                                controller
                                                                    .seachText
                                                                    .text;
                                                            controller.isLoading
                                                                .value = true;
                                                            controller
                                                                .getWeatherDetails(
                                                                    controller
                                                                        .seachText
                                                                        .text);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: Icon(
                                                              Icons.search)),
                                                      hintText:
                                                          'Enter city name',
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)))),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Forecast Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: width,
                      child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              Container(height: 2),
                          shrinkWrap: true,
                          addRepaintBoundaries: true,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) => Container(
                                height: height * 0.1,
                                width: width * 0.1,
                                child: forecastList[index],
                              ),
                          itemCount: forecastList.length),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
