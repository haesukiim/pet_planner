import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petplan/reservation_screen.dart';
import 'dart:async';

class First extends StatefulWidget {
  const First({Key? key}) : super(key: key);
  _First createState() => _First();
}

class _First extends State<First>{
  String? _selectedHotelName;
  static final LatLng companyLatLng = LatLng(
    36.833687, // 위도
    127.179960, //경도
  );
  final Completer<GoogleMapController> _controller = Completer();
  final List<Map<String, dynamic>> _visibleHotels = [];
  final _markers = <Marker>{};
  final _hotel = [
    {
      "name": "딩굴댕굴",
      "latitude": 36.834441,
      "longitude": 127.141998,
    },
    {
      "name": "럭셔리펫",
      "latitude": 36.832281,
      "longitude": 127.131000,
    },
    {
      "name": "달려봐요댕댕이숲",
      "latitude": 36.837061,
      "longitude": 127.131170,
    },
    {
      "name": "도그홀릭",
      "latitude": 36.773627,
      "longitude": 127.071561,
    },
  ];

  void initState() {
    _markers.addAll(
      _hotel.map(
            (e) => Marker(
          markerId: MarkerId(e['name'] as String),
          infoWindow: InfoWindow(title: e['name'] as String),
          position: LatLng(
            e['latitude'] as double,
            e['longitude'] as double,
          ),
        ),
      ),
    );
    super.initState();
  }

  void _updateVisibleHotels(LatLngBounds bounds) {
    final visibleHotels = _hotel.where((hotel) {
      final hotelLatLng = LatLng(hotel['latitude'] as double, hotel['longitude'] as double);
      return bounds.contains(hotelLatLng); // LatLngBounds 내의 마커만 필터링
    }).toList();

    setState(() {
      _visibleHotels.clear();
      _visibleHotels.addAll(visibleHotels);
    });
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: FutureBuilder<String>(
          future: checkPermission(),
          builder: (context, snapshot) {
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == '위치 권한이 허가 되었습니다.') {
              return Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: companyLatLng,
                            zoom: 13,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          markers: _markers,
                          onCameraIdle: () async {
                            final GoogleMapController controller = await _controller.future;
                            final bounds = await controller.getVisibleRegion(); // 현재 화면의 LatLngBounds 가져오기
                            _updateVisibleHotels(bounds);
                          },
                        ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: FloatingActionButton(
                            backgroundColor: Color(0xFFFFDC8B),
                            onPressed: _currentLocation,
                            child: const Icon(Icons.my_location),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: _visibleHotels.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final hotel = _visibleHotels[index];
                              final isSelected = _selectedHotelName == hotel['name'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedHotelName = hotel['name'] as String; // 선택된 호텔 이름 저장
                                  });
                                  final selectedLatLng = LatLng(
                                    hotel['latitude'] as double,
                                    hotel['longitude'] as double,
                                  );
                                  _controller.future.then((controller) {
                                    controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: selectedLatLng,
                                          zoom: 13.0,
                                        ),
                                      ),
                                    );
                                  });
                                },
                                child: Container(
                                  color: isSelected
                                      ? const Color(0xFFFFFAF0)
                                      : Colors.transparent,
                                  child: ListTile(
                                    title: Text(hotel['name'] as String),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedHotelName != null) { // 선택된 호텔이 있는지 확인
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservationScreen(
                                    selectedHotelName: _selectedHotelName!, // 선택된 이름 전달
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('호텔을 선택해주세요')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFDC8B),
                          ),
                          child: const Text('예약하기',style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Center(
                child: Text(
                  snapshot.data.toString(),
                ));
          }),
    );
  }



  AppBar renderAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        '예약',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      backgroundColor: Color(0xFFFFFAF0),
      elevation: 0,
    );
  }
  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();   // 위치 서비스 활성화여부 확인

    if (!isLocationEnabled) {  // 위치 서비스 활성화 안 됨
      return '위치 서비스를 활성화해주세요.';
    }
    LocationPermission checkedPermission = await Geolocator.checkPermission();  // 위치 권한 확인

    if (checkedPermission == LocationPermission.denied) {  // 위치 권한 거절됨
      // 위치 권한 요청하기
      checkedPermission = await Geolocator.requestPermission();
      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }
    // 위치 권한 거절됨 (앱에서 재요청 불가)
    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }
    return '위치 권한이 허가 되었습니다.'; // 위 모든 조건이 통과되면 위치 권한 허가완료
  }

  Future<void> _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    Location location = Location();

    // 현재 위치 가져오기
    try {
      final currentLocation = await location.getLocation();

      // 카메라를 현재 위치로 이동
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: 13.0,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치를 가져올 수 없습니다: $e')),
      );
    }
  }
}