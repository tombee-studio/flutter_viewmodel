import 'package:flutter_viewmodel/bases/view_model.dart';
import 'package:flutter/material.dart';

abstract class ViewModelWidget<T extends ViewModel> extends StatelessWidget {
  final T parentViewModel;
  const ViewModelWidget({super.key, required this.parentViewModel});
}
