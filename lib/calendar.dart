import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  String _selectedCategory = "개인";
  String _calendarView = "월간";
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  IconData _selectedIcon = Icons.pets;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      _loadEvents();
    } catch (error) {
      print("Failed to initialize Firebase: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firebase 초기화 실패: $error")),
      );
    }
  }

  void _loadEvents() async {
    try {
      FirebaseFirestore.instance.collection('events').snapshots().listen((snapshot) {
        Map<DateTime, List<Map<String, dynamic>>> loadedEvents = {};
        for (var doc in snapshot.docs) {
          try {
            DateTime eventDate = DateTime.parse(doc['date']);
            loadedEvents[eventDate] ??= [];
            loadedEvents[eventDate]!.add({
              'event': doc['event'],
              'icon': IconData(int.parse(doc['icon']), fontFamily: 'MaterialIcons'),
            });
          } catch (e) {
            print("Invalid event data in Firestore: $e");
          }
        }
        setState(() {
          _events = loadedEvents;
        });
      });
    } catch (e) {
      print("Failed to load events: $e");
    }
  }

  void _addEventToFirestore(DateTime date, String event, IconData icon) async {
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'date': date.toIso8601String(),
        'event': event,
        'icon': icon.codePoint.toString(),
      });
      _loadEvents();
    } catch (e) {
      print("Failed to add event to Firestore: $e");
    }
  }

  Color _getIconColor(IconData icon) {
    final iconColors = {
      Icons.pets.codePoint: Colors.blue,
      Icons.volunteer_activism.codePoint: Color(0xFFFFC0CB),
      Icons.shower.codePoint: Colors.cyan,
      Icons.local_hospital.codePoint: Colors.green,
      Icons.favorite.codePoint: Colors.pink,
      Icons.content_cut.codePoint: Colors.orange,
    };
    return iconColors[icon.codePoint] ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _calendarView == "월간"
                ? SfCalendar(
              key: UniqueKey(),
              view: CalendarView.month,
              initialDisplayDate: _focusedDay,
              headerHeight: 0,
              dataSource: _getDataSource(),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                dayFormat: 'E',
                monthCellStyle: MonthCellStyle(
                  todayBackgroundColor: Color(0xFFFFDC8B),
                ),
              ),
              selectionDecoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFFF8C00), // 테두리 색상 설정
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: Colors.transparent,
              ),
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null && details.appointments!.isNotEmpty) {
                  // appointments를 안전하게 캐스팅
                  final List<Appointment> tappedAppointments =
                  details.appointments!.cast<Appointment>();
                  _showEventListDialog(context, tappedAppointments);
                }
              },
              appointmentBuilder: (context, details) {
                if (details.appointments != null && details.appointments!.isNotEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: details.appointments!.map((appointment) {
                        final Appointment event = appointment as Appointment;
                        return Icon(
                          IconData(int.parse(event.notes!), fontFamily: 'MaterialIcons'),
                          color: _getIconColor(
                              IconData(int.parse(event.notes!), fontFamily: 'MaterialIcons')),
                          size: 16,
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox();
              },
            )
                : _buildListView(),
          ),
          if (_selectedCategory != "호텔") _buildFloatingActionButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFFFFDC8B)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFFFFDC8B)),
                      onPressed: () {},
                    ),
                  ],
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    value: "${_focusedDay.year}년 ${_focusedDay.month}월",
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFDC8B)),
                    items: _generateYearMonthDropdownItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          final parts = value.split(' ');
                          final year = int.parse(parts[0].replaceAll('년', ''));
                          final month = int.parse(parts[1].replaceAll('월', ''));
                          _focusedDay = DateTime(year, month, 1);
                        });
                      }
                    },
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFFDC8B)),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      color: Colors.white,
                      icon: const Icon(Icons.calendar_month, color: Color(0xFFFFDC8B)),
                      onSelected: (value) {
                        setState(() {
                          _calendarView = value;
                        });
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: "월간",
                          child: Row(
                            children: const [
                              Icon(Icons.grid_view, color: Colors.black),
                              SizedBox(width: 8),
                              Text("월간"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "리스트",
                          child: Row(
                            children: const [
                              Icon(Icons.list, color: Colors.black),
                              SizedBox(width: 8),
                              Text("리스트"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildCategoryButton("개인", _selectedCategory == "개인"),
                    const SizedBox(width: 8),
                    _buildCategoryButton("호텔", _selectedCategory == "호텔"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      key: ValueKey(_events.length),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        DateTime date = _events.keys.elementAt(index);
        List<Map<String, dynamic>> events = _events[date]!;
        return ListTile(
          key: ValueKey(date),
          title: Text(
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
          ),
          subtitle: Column(
            children: events.map((event) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(event['event']),
                  Icon(
                    event['icon'],
                    color: _getIconColor(event['icon']),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFFFDC8B),
          onPressed: () {
            _showTodoAddDialog(context);
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFDC8B) : Colors.grey[200],
          border: Border.all(
              color: isSelected ? const Color(0xFFFFDC8B) : Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showEventListDialog(BuildContext context, List<Object> appointments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Events List'),
          content: SingleChildScrollView(
            child: Column(
              children: appointments.map((appointment) {
                final Appointment event = appointment as Appointment;
                return ListTile(
                  leading: Icon(
                    IconData(int.parse(event.notes!), fontFamily: 'MaterialIcons'),
                    color: _getIconColor(
                        IconData(int.parse(event.notes!), fontFamily: 'MaterialIcons')),
                  ),
                  title: Text(event.subject),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTodoAddDialog(BuildContext context) {
    TextEditingController _todoController = TextEditingController();
    DateTime _selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFFFF),
              title: const Text(
                'Todo Add',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("할 일", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _todoController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(hintText: "일정을 적어주세요."),
                    ),
                    const SizedBox(height: 16),
                    const Text("날짜", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2040),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: const Color(0xFFFFDC8B), // 헤더 및 강조 색상
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFFFDC8B), // 헤더 색상
                                  secondary: Color(0xFFFFDC8B), // 선택된 날짜 색상
                                ),
                                dialogBackgroundColor: Colors.white, // 배경 흰색
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                            const SizedBox(width: 8),
                            Text(
                              "${_selectedDate.year}년 ${_selectedDate.month.toString().padLeft(2, '0')}월 ${_selectedDate.day.toString().padLeft(2, '0')}일",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("아이콘", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildIconChoice(Icons.pets, _selectedIcon, setState, Colors.blue),
                          _buildIconChoice(Icons.volunteer_activism, _selectedIcon, setState, Colors.pink),
                          _buildIconChoice(Icons.shower, _selectedIcon, setState, Colors.cyan),
                          _buildIconChoice(Icons.local_hospital, _selectedIcon, setState, Colors.green),
                          _buildIconChoice(Icons.favorite, _selectedIcon, setState, Colors.red),
                          _buildIconChoice(Icons.content_cut, _selectedIcon, setState, Colors.orange),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('취소', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    if (_todoController.text.isNotEmpty) {
                      setState(() {
                        if (_events[_selectedDate] == null) {
                          _events[_selectedDate] = [];
                        }
                        _events[_selectedDate]!.add({
                          'event': _todoController.text,
                          'icon': _selectedIcon,
                        });
                        _addEventToFirestore(
                            _selectedDate, _todoController.text, _selectedIcon);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('추가', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIconChoice(IconData icon, IconData selectedIcon, StateSetter setState, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIcon = icon;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: icon == selectedIcon ? Colors.grey[100] : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: icon == selectedIcon ? Color(0xFFFFDC8B): Colors.transparent,
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: color),
      ),
    );
  }

  List<DropdownMenuItem<String>> _generateYearMonthDropdownItems() {
    List<DropdownMenuItem<String>> items = [];
    for (int year = 2020; year <= 2040; year++) {
      for (int month = 1; month <= 12; month++) {
        items.add(DropdownMenuItem(
          value: "${year}년 ${month}월",
          child: Text("${year}년 ${month}월"),
        ));
      }
    }
    return items;
  }

  CalendarDataSource _getDataSource() {
    final List<Appointment> appointments = <Appointment>[];
    _events.forEach((date, eventList) {
      for (var event in eventList) {
        appointments.add(Appointment(
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          subject: event['event'],
          notes: event['icon'].codePoint.toString(),
        ));
      }
    });
    return AppointmentDataSource(appointments);
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CalendarScreen(),
  ));
}