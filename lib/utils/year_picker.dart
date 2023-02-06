import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomYearchPicker extends DatePickerModel {
  CustomYearchPicker(
      {DateTime? currentTime,
      DateTime? minTime,
      DateTime? maxTime,
      LocaleType? locale})
      : super(
            locale: locale,
            minTime: minTime,
            maxTime: maxTime,
            currentTime: currentTime);

  @override
  List<int> layoutProportions() {
    return [1, 0, 0];
  }
}
