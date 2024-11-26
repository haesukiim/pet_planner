import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'community.dart';

class ReservationTextField extends StatelessWidget {
  final String label;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;

  ReservationTextField({
    required this.label,
    this.onSaved,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 2,
                //strokeAlign: StrokeAlign.outside
              ),
            ),
            errorStyle: TextStyle(),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.orange,
                width: 2,
              ),
            ),
          ),
          onSaved: onSaved,
          validator: validator,
          inputFormatters: inputFormatters,
        ),
        Container(height: 16.0),
      ],
    );
  }
}

class ReservationScreen extends StatefulWidget {
  final String selectedHotelName;
  const ReservationScreen({Key? key, required this.selectedHotelName}) : super(key: key);

  _ReservationScreen createState() => _ReservationScreen();
}

class _ReservationScreen extends State<ReservationScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  bool _isSwitched = true;
  bool isMale = false;
  bool isFemale = false;
  bool isNeuter = false;
  bool isNeuterX = false;
  late List<bool> isSelected1;
  late List<bool> isSelected2;
  DateTime? _selectedStartDate;
  DateTime? _selectedLastDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  String name = '';
  String num = '';
  String memo = '';

  String petName = '';
  String breed = '';
  var age1;
  var age2;
  String revMemo = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: this.formKey,
      child: SafeArea(
        child: Scaffold(
          appBar: renderAppBar(),
          body: SingleChildScrollView(
            child: Column(
              //보호자, 동물, 호텔
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                    children: [
                      Text(
                        '보호자 정보',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ReservationTextField(
                          label: '보호자 호칭 *',
                          onSaved: (val) {
                            setState(() {
                              this.name = val ?? '';
                            });
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return '필수사항입니다.';
                            }
                            //return null;
                          }),
                      SizedBox(height: 10),
                      ReservationTextField(
                        label: '휴대폰 번호 *',
                        onSaved: (val) {
                          setState(() {
                            this.num = val ?? '';
                          });
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return '필수사항입니다.';
                          } else if (val.length < 11) {
                            return '유효한 전화번호를 입력하세요.';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                        ],
                      ),
                      SwitchListTile(
                        title: Text('알림톡 수신(예약 알림)'),
                        value: _isSwitched,
                        onChanged: (value) {
                          setState(() {
                            _isSwitched = value;
                          });
                        },
                        activeTrackColor: Color(0xFFFFDC8B),
                        inactiveTrackColor: Color(0xFFFFFAF0),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '보호자 메모',
                        ),
                        onSaved: (val) {
                          setState(() {
                            this.memo = val ?? '';
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                    children: [
                      Text(
                        '강아지 정보',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),
                      ReservationTextField(
                          label: '반려동물 이름 *',
                          onSaved: (val) {
                            setState(() {
                              this.petName = val ?? '';
                            });
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return '필수사항입니다.';
                            }
                            return null;
                          }),
                      ReservationTextField(
                          label: '품종',
                          onSaved: (val) {
                            setState(() {
                              this.breed = val ?? '';
                            });
                          },
                          validator: (val) {
                            return null;
                          }),
                      SizedBox(height: 20),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ToggleButtons(
                              children: <Widget>[
                                Text('암컷',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black)),
                                Text('수컷',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black)),
                              ],
                              isSelected: isSelected1,
                              onPressed: toggleSelect1,
                              borderRadius: BorderRadius.circular(20),
                              fillColor: Color(0xFFFFDC8B),
                              constraints: BoxConstraints(
                                minHeight: 50, // 버튼 높이
                                minWidth:
                                (MediaQuery.of(context).size.width - 100) /
                                    2,
                              ),
                            ),
                            SizedBox(height: 10),
                            ToggleButtons(
                              children: <Widget>[
                                Text('중성화 O',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black)),
                                Text('중성화 X',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black)),
                              ],
                              isSelected: isSelected2,
                              onPressed: toggleSelect2,
                              borderRadius: BorderRadius.circular(20),
                              fillColor: Color(0xFFFFDC8B),
                              constraints: BoxConstraints(
                                minHeight: 50, // 버튼 높이
                                minWidth:
                                (MediaQuery.of(context).size.width - 100) /
                                    2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '나이',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSaved: (val) {
                                setState(() {
                                  this.age1 = val ?? '';
                                });
                              },
                            ),
                          ),
                          Text(
                            '살',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSaved: (val) {
                                setState(() {
                                  this.age2 = val ?? '';
                                });
                              },
                            ),
                          ),
                          Text(
                            '개월',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                    children: [
                      Text(
                        '예약 정보',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        '선택된 호텔',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        '${widget.selectedHotelName}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: [
                          Expanded(
                            child: buildDateField(),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: buildLastDateField(),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: buildTimeField(isStartTime: true),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: buildTimeField(isStartTime: false),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
                SizedBox(height: 20), // 간격 추가
                Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                    children: [
                      Text(
                        '예약 메모',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 6,
                        onSaved: (val) {
                          setState(() {
                            this.revMemo = val ?? '';
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSavePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDC8B),
                    ),
                    child: Text(
                      '예약 접수',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar renderAppBar() {
    // AppBar를 구현하는 함수
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

  Widget buildDateField() {
    return FormField<DateTime>(
      validator: (value) {
        if (value == null) {
          return '필수사항입니다.';
        }
        return null;
      },
      onSaved: (value) {
        print('체크인: $value');
      },
      builder: (FormFieldState<DateTime> state) {
        return GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedStartDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              state.didChange(picked);
              setState(() {
                _selectedStartDate = picked;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '예약일 *',
                style: TextStyle(fontSize: 15.0),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: state.hasError ? Color(0xFFB00020) : Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedStartDate != null
                          ? _formatDate(_selectedStartDate)
                          : '날짜 선택',
                      style: TextStyle(fontSize: 15),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: Color(0xFFB00020), fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  Widget buildLastDateField() {
    return FormField<DateTime>(
      validator: (value) {
        if (value == null) {
          return '필수사항입니다.';
        }
        return null;
      },
      onSaved: (value) {
        print('체크 아웃: $value');
      },
      builder: (FormFieldState<DateTime> state) {
        return GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedLastDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              state.didChange(picked);
              setState(() {
                _selectedLastDate = picked;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '',
                style: TextStyle(fontSize: 15.0),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: state.hasError ? Color(0xFFB00020) : Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedLastDate != null
                          ? _formatDate(_selectedLastDate)
                          : '날짜 선택',
                      style: TextStyle(fontSize: 15),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: Color(0xFFB00020), fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTimeField({required bool isStartTime}) {
    return FormField<TimeOfDay>(
      validator: (value) {
        if (value == null) {
          return isStartTime ? '필수사항입니다.' : '필수사항입니다.';
        }
        if (isStartTime) {
          if (value.hour < 8) {
            return '오전 8시부터 가능';
          }
        } else {
          if (value.hour >= 22) {
            return '오후 10시까지 가능';
          }
          if (_selectedStartDate == _selectedLastDate){
            if (_selectedStartTime != null &&
                (value.hour < _selectedStartTime!.hour ||
                    (value.hour == _selectedStartTime!.hour &&
                        value.minute <= _selectedStartTime!.minute))) {
              return '종료 시간은 시작 시간 이후여야 합니다.';
            }
          }
        }
        return null;
      },
      onSaved: (value) {
        if (isStartTime) {
          print('저장된 시작 시간: $value');
        } else {
          print('저장된 종료 시간: $value');
          print('호텔 이름 : ${widget.selectedHotelName}');
        }
      },
      builder: (FormFieldState<TimeOfDay> state) {
        return GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              state.didChange(picked);
              setState(() {
                if (isStartTime) {
                  _selectedStartTime = picked;
                } else {
                  _selectedEndTime = picked;
                }
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isStartTime ? '시작 시간 *' : '종료 시간 *',
                style: TextStyle(fontSize: 15.0),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: state.hasError ? Color(0xFFB00020) : Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isStartTime
                          ? (_selectedStartTime != null
                          ? _formatTime(_selectedStartTime)
                          : '시간 선택')
                          : (_selectedEndTime != null
                          ? _formatTime(_selectedEndTime)
                          : '시간 선택'),
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.access_time),
                  ],
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: Color(0xFFB00020), fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
/*
  Widget buildRegionDropdown() {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      child: DropdownButtonFormField(
        hint: Text('지역 선택'),
        isExpanded: true,
        value: _selectRegion,
        items: _valueRegion.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectRegion = value;
            _selectValue = null;
          });
          formKey.currentState?.validate();
        },
        onSaved: (val) {},
        validator: (val) {
          if (val == null || (val as String).isEmpty) {
            return '필수사항입니다.';
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdown() {
    List<String> dropdownItems = _selectRegion == '서울'
        ? _valueListSeoul
        : _selectRegion == '천안'
            ? _valueListCheonan
            : [];

    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      child: DropdownButtonFormField(
        hint: Text('호텔 선택'),
        isExpanded: true,
        value: _selectValue,
        items: dropdownItems.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectValue = value!;
          });
          formKey.currentState?.validate();
        },
        onSaved: (val) {},
        validator: (val) {
          if (val == null || (val as String).isEmpty) {
            return '필수사항입니다.';
          }
          return null;
        },
      ),
    );
  }
*/
  void initState() {
    isSelected1 = [isFemale, isMale];
    isSelected2 = [isNeuter, isNeuterX];
    super.initState();
  }

  void toggleSelect1(value) {
    if (value == 0) {
      isFemale = true;
      isMale = false;
    } else {
      isFemale = false;
      isMale = true;
    }
    setState(() {
      isSelected1 = [isFemale, isMale];
    });
  }

  void toggleSelect2(value) {
    if (value == 0) {
      isNeuter = true;
      isNeuterX = false;
    } else {
      isNeuter = false;
      isNeuterX = true;
    }
    setState(() {
      isSelected2 = [isNeuter, isNeuterX];
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '날짜 선택';
    return DateFormat('yyyy.MM.dd.').format(date);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '시간 선택';
    final now = DateTime.now();
    final formattedTime = DateFormat.jm().format(
      DateTime(now.year, now.month, now.day, time.hour, time.minute),
    );
    return formattedTime;
  }

  void onSavePressed() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final Map<String, int> age = {
        'years': int.tryParse(age1 ?? '0') ?? 0,
        'months': int.tryParse(age2 ?? '0') ?? 0,
      };

      String sex = isSelected1[0] ? '암컷' : (isSelected1[1] ? '수컷' : '미정');
      String neuter = isSelected2[0] ? '중성화 O' : (isSelected2[1] ? '중성화 X' : '미정');

      final Map<String, dynamic> reservationData = {
        'name': name,
        'num': num,
        'adver': _isSwitched,
        'memo': memo,
        'petName': petName,
        'breed': breed,
        'sex': sex,
        'neuter': neuter,
        'age': age,
        'hotel': widget.selectedHotelName,
        'selectedStartDate': _selectedStartDate?.toIso8601String(),
        'selectedLastDate': _selectedLastDate?.toIso8601String(),
        'startTime': _selectedStartTime?.format(context),
        'endTime': _selectedEndTime?.format(context),
        'rev_Memo': revMemo,
      };

      try {
        await FirestoreService().saveReservation(reservationData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예약이 성공적으로 저장되었습니다!')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => CommunityScreen()),
              (route) => false, // 이전 화면 스택 제거
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예약 저장 실패: $e')),
        );
      }
    }
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveReservation(Map<String, dynamic> reservationData) async {
    try {
      String documentId = Uuid().v4();

      await _firestore
          .collection('reservation')
          .doc(documentId)
          .set(reservationData);

      debugPrint('예약 데이터가 성공적으로 저장되었습니다.');
    } catch (e) {
      debugPrint('예약 데이터 저장 중 오류 발생: $e');
      throw e;
    }
  }
}