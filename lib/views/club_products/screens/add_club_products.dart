import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:club_model/club_model.dart';
import '../../common/components/common_image_view_box.dart';
import '../../common/components/common_text_form_field.dart';
import '../../common/components/get_title.dart';
import '../../common/components/header_widget.dart';

class AddClubProducts extends StatefulWidget {
  static const String routeName = "/AddClubProducts";
  const AddClubProducts({Key? key}) : super(key: key);

  @override
  State<AddClubProducts> createState() => _AddClubProductsState();
}

class _AddClubProductsState extends State<AddClubProducts> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late Future<void> futureGetData;

  Future<void> getData() async {

  }

  @override
  void initState() {
    super.initState();
    futureGetData = getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureGetData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: Styles.bgColor,
            body: ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    HeaderWidget(title:"Add Club Products", isBackArrow: true),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const LoadingWidget();
        }
      },
    );
  }
}
