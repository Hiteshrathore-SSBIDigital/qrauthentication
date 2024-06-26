import 'dart:convert';

import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nehhdc_app/Model_Screen/APIs_Screen.dart';
import 'package:nehhdc_app/Model_Screen/JSON_Screen.dart';
import 'package:nehhdc_app/Screen/Bottom_Screen.dart';
import 'package:nehhdc_app/Screen/Home_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Static_Verible';
import 'package:path/path.dart' as path;

class Registered_User extends StatefulWidget {
  const Registered_User({Key? key}) : super(key: key);

  @override
  State<Registered_User> createState() => _Registered_UserState();
}

class _Registered_UserState extends State<Registered_User> {
  final TempOrgAPIs apis = TempOrgAPIs();
  late Future<Temporg> item;

  TextEditingController firstcontroller = TextEditingController();
  TextEditingController lastcontroller = TextEditingController();
  TextEditingController datecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController doccontroller = TextEditingController();
  TextEditingController _weaverIdController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  late List<String> states;
  late Map<String, List<String>> districtDepartments = {};
  late Map<String, List<String>> stateDepartments = {};
  late Map<String, List<String>> districtVillages = {};

  List<String> districts = ['Select District'];
  List<String> villages = ['Select City'];
  List<String> department = ['Select Department'];
  String selectedState = 'Select State';
  String selectedDistrict = 'Select District';
  String selectedDepartment = 'Select Department';
  String selectedVillage = 'Select City';

  bool showErrorMessage = false;
  bool dataerrormassage = false;
  bool organizationSelected = false;
  bool organizationTextFieldVisible = false;
  bool WeaverTextFieldVisible = false;
  DateTime selectdobdate = DateTime.now();
  bool isInserting = false;
  bool selectdocenable = false;
  bool selectgenderenable = false;

  bool selectstateenable = false;
  bool selectdistrricteenable = false;
  bool selectcityeenable = false;

  bool selectdeparmenteenable = false;
  bool selectrolevisiable = false;
  bool selecttypeenable = false;
  bool selectroleenable = true;
  late List<String> departments;
  late List<String> distric = [];
  late List<String> genders;
  late List<String> type;
  late List<String> Role;
  late List<String> doc;
  String selectedGender = '';
  String selecttype = '';
  String selectrole = '';
  String selectdoc = '';
  bool Orgvalidate = false;
  bool fistvalidate = false;
  bool lastvalidate = false;
  bool datevalidate = false;
  bool emailvalidate = false;
  bool mobilevalidate = false;
  bool docvalidate = false;
  File? imageFile = null;

  String errorText = '';
  String testfailed = '';
  DateTime firstDateYear = DateTime(1870);

  DateTime selectDobDate = DateTime.now();
  DateTime lastDate = DateTime.now();

  String _validateDate(DateTime date) {
    // Calculate minimum date (18 years ago)
    DateTime minDate = DateTime.now().subtract(Duration(days: 18 * 365));

    // Check if entered date is after or exactly 18 years ago
    if (date.isAfter(minDate) || date.difference(minDate).inDays == 0) {
      datecontroller.text = '';
      return "Must be 18 years or older";
    } else {
      return '';
    }
  }

  @override
  void dispose() {
    datecontroller.dispose();
    super.dispose();
  }

  Future<void> _uploadDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      int imageSize = await imageFile!.length();

      double imageSizeInMB = imageSize / (1024 * 1024);

      if (imageSizeInMB <= 1) {
        String fileName = path.basename(pickedFile.path);

        setState(() {
          docvalidate = true;
          doccontroller.text = fileName;
          testfailed = pickedFile.path;
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Upload Document Size Limit Exceeded !',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Please select an document with a maximum size of 1MB.',
                style: TextStyle(fontSize: 13),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // User canceled the image picker
      // Handle accordingly
    }
  }

  void validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        emailvalidate = true;
      } else if (!email.contains('@') || !email.contains('.')) {
        emailvalidate = true;
      } else {
        emailvalidate = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    firstcontroller.text = staticverible.fistname ?? '';
    lastcontroller.text = staticverible.lastname ?? '';
    emailcontroller.text = staticverible.email ?? '';
    datecontroller.text = staticverible.dateofbirth ?? '';
    mobilecontroller.text = staticverible.mobileno ?? '';
    doccontroller.text = staticverible.docno ?? '';
    organizationController.text = staticverible.organization ?? '';
    mobilecontroller.text = staticverible.mobileno ?? '';
    // Initialize gender selection
    genders = ['Select Gender', 'Male', 'Female'];
    selectedGender = genders.first;

    // Initialize type selection
    type = ['Select Type', 'Own', 'Organization'];
    selecttype = type.first;

    // Initialize role selection
    Role = StaticRole.roles;
    selectrole = Role.first;

    if (Role.contains(staticverible.rolename)) {
      selectrole = staticverible.rolename;
    }

    // Initialize document selection
    doc = ['Select Document', 'Aadhar Card', 'Pan Card', 'Voter Id'];
    selectdoc = doc.first;

    // Decode JSON data
    String jsonData = getjsonData;
    Map<String, dynamic> decodedJson = jsonDecode(jsonData);

    // Initialize states, districts, and departments
    states = ['Select State'];
    districtDepartments = {};
    stateDepartments = {};
    districtVillages = {};

    if (decodedJson.containsKey('states')) {
      for (var stateData in decodedJson['states'] ?? []) {
        var stateName = stateData['name'].toString();
        states.add(stateName);

        var districtList = (stateData['districts'] as List<dynamic>?)
                ?.map((district) => district.toString())
                .toList() ??
            [];
        districtDepartments[stateName] = districtList;

        var departmentList = (stateData['department'] as List<dynamic>?)
                ?.map((department) => department.toString())
                .toList() ??
            [];
        stateDepartments[stateName] = departmentList;

        var districtVillageMap = <String, List<String>>{};
        for (var districtData in stateData['districts_Village'] ?? []) {
          var districtName = districtData['name'].toString();
          var villageList = (districtData['city'] as List<dynamic>?)
                  ?.map((village) => village.toString())
                  .toList() ??
              [];
          districtVillageMap[districtName] = villageList;
        }

        districtVillages[stateName] =
            districtVillageMap.values.expand((villages) => villages).toList();
      }
    }

    // Ensure unique villages in the list
    Set<String> uniqueVillages = {};
    for (var districtVillageList in districtVillages.values) {
      uniqueVillages.addAll(districtVillageList);
    }

    villages = ['Select City'];
    selectedState =
        staticverible.state.isNotEmpty ? staticverible.state : 'Select State';
    selectedDistrict = staticverible.distric.isNotEmpty
        ? staticverible.distric
        : 'Select District';
    selectedDepartment = staticverible.department.isNotEmpty
        ? staticverible.department
        : 'Select Department';
    selectedVillage =
        staticverible.city.isNotEmpty ? staticverible.city : 'Select City';

    selecttype =
        staticverible.type.isNotEmpty ? staticverible.type : 'Select Type';

    // Update lists based on initial selections
    _updateDistrictList(selectedState);
    _updateDepartmentList(selectedState);
    villages = _updateVillageList(selectedDistrict, decodedJson);
  }

  void _updateDistrictList(String selectedState) {
    setState(() {
      if (selectedState != 'Select State' &&
          districtDepartments.containsKey(selectedState)) {
        if (!districtDepartments[selectedState]!.contains(selectedDistrict)) {
          selectedDistrict = 'Select District';
        }
        districts = ['Select District', ...districtDepartments[selectedState]!];
      } else {
        districts = ['Select District'];
        selectedDistrict = 'Select District';
      }
    });
  }

  void _updateDepartmentList(String selectedState) {
    setState(() {
      if (selectedState != 'Select State' &&
          stateDepartments.containsKey(selectedState)) {
        department = ['Select Department', ...stateDepartments[selectedState]!];
      } else {
        department = ['Select Department'];
        selectedDepartment = 'Select Department';
      }
    });
  }

  List<String> _updateVillageList(
      String selectedDistrict, Map<String, dynamic> decodedJson) {
    List<String> updatedVillages = [];

    if (selectedDistrict != 'Select District') {
      var stateData = decodedJson['states'].firstWhere(
          (state) => state['name'] == selectedState,
          orElse: () => null);
      if (stateData != null) {
        var districtData = stateData['districts_Village'].firstWhere(
            (district) => district['name'] == selectedDistrict,
            orElse: () => null);
        if (districtData != null) {
          var cityList = districtData['city'] as List<dynamic>? ?? [];
          updatedVillages =
              cityList.toSet().map((city) => city.toString()).toList();
        }
      }
    }

    if (updatedVillages.isEmpty) {
      updatedVillages = ['Select City'];
    }

    return updatedVillages;
  }

  void _handleChanged(String value) {
    // Remove any non-digit characters from the input
    String sanitizedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (sanitizedValue.length <= 10) {
      // Do something with the input value, e.g., store it or process it
      print('Input: $value');
    } else {
      // Notify user that only 10 values are allowed
      print('Only 10 values are allowed');
      // Truncate the input to 10 characters
      sanitizedValue = sanitizedValue.substring(0, 10);
    }

    // Check if the entered value is a valid 10-digit mobile number
    if (sanitizedValue.length == 10 &&
        !RegExp(r'^[0-9]+$').hasMatch(sanitizedValue)) {
      // Clear the text field if the entered value is not a valid 10-digit number
      setState(() {
        mobilecontroller.clear();
      });
    }

    // Set the processed value back to the text field
    setState(() {
      mobilecontroller.value = mobilecontroller.value.copyWith(
        text: sanitizedValue,
        selection: TextSelection.collapsed(offset: sanitizedValue.length),
      );
    });

    // Update the isValidMobile variable based on the validity of the mobile number
    mobilevalidate = sanitizedValue.length == 10 &&
        RegExp(r'^[0-9]+$').hasMatch(sanitizedValue);
  }

  void _navigateToHomeScreen(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => Bottom_Screen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registration Update",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            _navigateToHomeScreen(context);
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(ColorVal),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Column(
              children: [
                // State Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "State",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedState,
                          items: states.map((String state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  state,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: null,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: selectstateenable &&
                          selectedState == states.first &&
                          selectedState != '',
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              "Please select a state",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),

                // District Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Districts",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 36,
                      width: double.infinity, // Take up full width of parent
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: selectedDistrict,
                            items: districts.map((String district) {
                              return DropdownMenuItem<String>(
                                value: district,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    district,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: null),
                      ),
                    ),
                    Visibility(
                      visible: selectdistrricteenable &&
                          selectedDistrict == districts.first &&
                          selectedDistrict != '',
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "Please select a district",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            // Sencode row
            Column(
              children: [
                // Department Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Department",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 36,
                      width: double.infinity, // Take up full width of parent
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: selectedDepartment,
                            items: department.map((String department) {
                              return DropdownMenuItem<String>(
                                value: department,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    department,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: null),
                      ),
                    ),
                    Visibility(
                      visible: selectdeparmenteenable &&
                          selectedDepartment == department.first &&
                          selectedDepartment != '',
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "Please select a department",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),

                // Type Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Type",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 36,
                      width: double.infinity, // Take up full width of parent
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: selecttype,
                            items: type.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: null),
                      ),
                    ),
                    Visibility(
                      visible: selecttypeenable &&
                          selecttype == type.first &&
                          selecttype != '',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "Please select a type",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            // 3thd
            Column(
              children: [
                // City Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "City",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: selectedVillage,
                            items: [
                              if (!villages.contains('Select City'))
                                DropdownMenuItem<String>(
                                  value: 'Select City',
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Text(
                                      "Select City",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ...villages.map((String village) {
                                return DropdownMenuItem<String>(
                                  value: village,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      village,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: null),
                      ),
                    ),
                    Visibility(
                      visible: selectcityeenable &&
                          selectedVillage == villages.first &&
                          selectedVillage != '',
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "Please select a city",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),

                // Role Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Role",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectrole,
                          items: Role.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: null,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: selectrolevisiable &&
                          selectrole == Role.first &&
                          selectrole != '',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "Please select a role",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Visibility(
              visible: WeaverTextFieldVisible,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weaver Id",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 36,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(width: 0, color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, bottom: 5),
                      child: TextField(
                        controller: _weaverIdController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(border: InputBorder.none),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: showErrorMessage && WeaverTextFieldVisible,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        'Please enter Weaver id',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selecttype == 'Organization')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Organization",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 36,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(width: 0, color: Colors.grey),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 15),
                          child: TextField(
                            enabled: false,
                            controller: organizationController,
                            style: TextStyle(fontSize: 12),
                            decoration:
                                InputDecoration(border: InputBorder.none),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            showErrorMessage && organizationTextFieldVisible,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Please enter organization',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                // Add other widgets as needed
              ],
            ),
            SizedBox(height: 10),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "First Name",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 36,
                            width: MediaQuery.of(context).size.width / 2.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(width: 0, color: Colors.grey),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5, bottom: 15),
                              child: TextField(
                                controller: firstcontroller,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                    enabled: false, border: InputBorder.none),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          if (fistvalidate)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                'Please enter name',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Last Name",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                              height: 36,
                              width: MediaQuery.of(context).size.width / 2.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                border:
                                    Border.all(width: 0, color: Colors.grey),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, bottom: 15),
                                child: TextField(
                                  controller: lastcontroller,
                                  style: TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                      enabled: false, border: InputBorder.none),
                                  textAlign: TextAlign.left,
                                ),
                              )),
                          if (fistvalidate)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                'Please enter last name',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gender",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          height: 36,
                          width: MediaQuery.of(context).size.width / 2.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              width: 0,
                              color: Colors.grey,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedGender,
                              items: genders.map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      gender,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {},
                            ),
                          )),
                      Visibility(
                        visible: selectgenderenable &&
                            selectedGender == genders.first &&
                            selectedGender != '',
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "Please select a gender",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          )
                        ]),
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date of birth",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 36,
                      width: MediaQuery.of(context).size.width / 2.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(width: 0, color: Colors.grey),
                      ),
                      child: AbsorbPointer(
                        absorbing: false,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 15),
                          child: TextField(
                            decoration: InputDecoration(
                              enabled: false,
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.none,
                            controller: datecontroller,
                            style: TextStyle(fontSize: 12),
                            onTap: () async {
                              DateTime minDate = DateTime(1870);

                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectdobdate.isBefore(lastDate)
                                    ? selectdobdate
                                    : lastDate,
                                firstDate: minDate,
                                lastDate: lastDate,
                              );
                              if (pickedDate != null &&
                                  pickedDate != selectDobDate) {
                                setState(() {
                                  selectDobDate = pickedDate;
                                  datecontroller.text = DateFormat('dd-MM-yyyy')
                                      .format(selectDobDate);
                                  errorText = _validateDate(
                                      selectDobDate); // Update errorText
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    if (datevalidate || errorText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          datevalidate
                              ? 'Please enter date of birth'
                              : errorText,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(width: 0, color: Colors.grey)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 15),
                        child: TextField(
                          decoration: InputDecoration(
                              enabled: false, border: InputBorder.none),
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.left, // Align text to the left
                          onChanged: (value) {
                            setState(() {
                              validateEmail(value);
                            });
                          },
                          controller: emailcontroller,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    if (emailvalidate)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'Please enter email',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mobile No",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(width: 0, color: Colors.grey)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 15),
                        child: TextField(
                          onChanged: _handleChanged,
                          controller: mobilecontroller,
                          style: TextStyle(fontSize: 12),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              enabled: false, border: InputBorder.none),
                        ),
                      ),
                    ),
                    if (mobilevalidate && mobilecontroller.text.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'Please enter mobile no',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (!mobilevalidate &&
                        mobilecontroller.text.isNotEmpty &&
                        mobilecontroller.text.length !=
                            10) // Display error message if entered number is not 10 digits
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Text(
                          'Invalid Mobile No',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Document",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 35,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                border:
                                    Border.all(width: 0, color: Colors.grey)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectdoc,
                                items: doc.map((String doc) {
                                  return DropdownMenuItem<String>(
                                    value: doc,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        doc,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    if (value == doc.first) {
                                      return;
                                    } else {
                                      selectdoc = value!;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: selectdocenable &&
                                selectdoc == doc.first &&
                                selectdoc != '',
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    "Please select a document",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Upload Document",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: _uploadDocument,
                          child: Container(
                            height: 35,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(width: 0, color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    doccontroller.text.isEmpty
                                        ? 'Select Document'
                                        : doccontroller.text.split('/').last,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (docvalidate &&
                            doccontroller.text
                                .isEmpty) // Display the error message only if docvalidate is true
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Please upload document',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                      ],
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            InkWell(
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width / 2.5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Color(ColorVal)),
                child: Center(
                    child: Text(
                  "Submit",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
              ),
              onTap: () {
                //       TemponTap();
              },
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class StaticRole {
  static const List<String> roles = [
    'Select Role',
    'Weaver',
    'Manager',
    'Supervisor',
    'Super Admin'
  ];
}
