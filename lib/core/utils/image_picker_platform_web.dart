import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';

void setImagePickerPlatform() {
  ImagePickerPlatform.instance = ImagePickerPlugin();
}
