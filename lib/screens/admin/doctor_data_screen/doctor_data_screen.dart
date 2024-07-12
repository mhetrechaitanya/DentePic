import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/screens/admin/doctor_manage_screen/doctor_manage.dart';
import 'package:Dentepic/widgets/custom_search_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorDataScreen extends StatefulWidget {
  DoctorDataScreen({Key? key}) : super(key: key);

  @override
  _DoctorDataScreenState createState() => _DoctorDataScreenState();
}

class _DoctorDataScreenState extends State<DoctorDataScreen> {
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> _allDoctors = [];
  List<DocumentSnapshot> _filteredDoctors = [];
  String sortOption = 'Assigned'; // Default sort option
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    fetchDoctors();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredDoctors = _allDoctors.where(
        (doc) => doc['fullName'].toLowerCase().contains(
          searchController.text.toLowerCase(),
        ),
      ).toList();
    });
  }

  Future<void> fetchDoctors() async {
    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference doctorsCollection = firestore.collection('doctors');
    QuerySnapshot snapshot = await doctorsCollection.get();

    setState(() {
      _allDoctors = snapshot.docs;
      _filteredDoctors = snapshot.docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.light ? Colors.black : appTheme.blue50,))
            : _buildDoctorData(),
      ),
    );
  }

  Widget _buildDoctorData() {
    _filteredDoctors.sort((a, b) {
      String statusA = a['status'];
      if (sortOption == 'Assigned') {
        return statusA == 'AS' ? -1 : 1;
      } else if (sortOption == 'Available') {
        return statusA == 'AV' ? -1 : 1;
      } else {
        return statusA == 'NA' ? -1 : 1;
      }
    });

    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          SizedBox(height: 25.v),
          Padding(
            padding: EdgeInsets.only(left: 35.h, right: 36.h),
            child: CustomSearchView(
              controller: searchController,
              hintText: "Search by doctor's name",
              hintStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey // Grey color for light theme
                    : Colors.white, // White color for dark theme
              ),
              autofocus: false,
              textStyle: CustomTextStyles.titleSmallGray200,
              fillColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white // Grey color for light theme
                  : Colors.black,
            ),
          ),
          SizedBox(height: 6.v),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 36.h),
                child: Text(
                  "Doctors Data",
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 36.h),
                child: DropdownButton<String>(
                  value: sortOption,
                  dropdownColor: Theme.of(context).brightness == Brightness.light ?  Colors.white :Colors.black ,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  items: <String>['Assigned', 'Available', 'Not Available']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      sortOption = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 15.v),
          _isLoading
            ? Center(child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.light ? Colors.black : appTheme.blue50,))
            : _buildDoctorsList(context, _filteredDoctors),
        ],
      ),
    );
  }

  Widget _buildDoctorsList(BuildContext context, List<DocumentSnapshot> doctors) {
    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 35.h),
        separatorBuilder: (context, index) => SizedBox(height: 13.v),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          String docId = doctors[index].id;
          String name = doctors[index]['fullName'];
          String status = doctors[index]['status'];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailScreen(
                    doctorId: docId,
                  ),
                ),
              ).then((value) {
                if (value == true) {
                  // Refresh the page or perform any desired action
                  setState(() {
                    fetchDoctors();
                  });
                }
              });
            },
            child: _buildDoctorItem(context, name, status),
          );
        },
      ),
    );
  }

  Widget _buildDoctorItem(BuildContext context, String name, String status) {
    if (status == 'AS') {
      return _buildAssigned(context, name);
    } else if (status == 'AV') {
      return _buildAvailable(context, name);
    } else {
      return _buildNotAvailable(context, name);
    }
  }

  Widget _buildAssigned(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 23.h, vertical: 7.v),
      decoration: AppDecoration.fillTeal.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder13,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 7.h, top: 21.v, bottom: 18.v),
            child: Text(
              "Dr. " + name,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.black,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 43.adaptSize,
                width: 43.adaptSize,
                decoration: BoxDecoration(
                  color: appTheme.lightBlue800,
                  borderRadius: BorderRadius.circular(21.h),
                ),
              ),
              SizedBox(height: 1.v),
              Text(
                "Assigned",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailable(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 23.h, vertical: 9.v),
      decoration: AppDecoration.fillTeal.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder13,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 7.h, top: 20.v, bottom: 17.v),
            child: Text(
              "Dr. " + name,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.black,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 43.adaptSize,
                width: 43.adaptSize,
                decoration: BoxDecoration(
                  color: appTheme.greenA40001,
                  borderRadius: BorderRadius.circular(21.h),
                ),
              ),
              Text(
                "Available",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotAvailable(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 9.v),
      decoration: AppDecoration.fillTeal.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder13,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 18.h, top: 18.v, bottom: 19.v),
            child: Text(
              "Dr. " + name,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.black,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 43.adaptSize,
                width: 43.adaptSize,
                decoration: BoxDecoration(
                  color: appTheme.deepOrangeA700,
                  borderRadius: BorderRadius.circular(21.h),
                ),
              ),
              Text(
                "Not Available",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
