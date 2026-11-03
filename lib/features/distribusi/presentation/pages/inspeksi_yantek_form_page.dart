import 'package:flutter/material.dart';
import 'detail_sutm_page.dart';

class InspeksiYantekFormPage extends StatelessWidget {
  final Map<String, dynamic> params;

  const InspeksiYantekFormPage({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    return DetailSutmPage(params: params);
  }
}
