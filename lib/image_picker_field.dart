import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerFormField extends FormField<File?> {
  ImagePickerFormField({
    super.key,
    ImagePickerInputController? controller,
    ValueChanged<File?>? onChanged,
    super.validator,
    super.autovalidateMode,
  }) : super(
          initialValue: controller?.value,
          builder: (state) {
            void onChangedHandler(File? value) {
              state.didChange(value);
              if (onChanged != null) {
                onChanged(value);
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImagePickerField(
                    controller: controller,
                    side: state.hasError
                        ? const BorderSide(color: Colors.red, width: 2)
                        : BorderSide.none,
                    onChanged: onChangedHandler,
                  ),
                  if (state.hasError) ...[
                    Text(
                      state.errorText!,
                      style: const TextStyle(fontSize: 15, color: Colors.red),
                    ),
                  ],
                ],
              ),
            );
          },
        );
}

class ImagePickerField extends StatefulWidget {
  const ImagePickerField({
    Key? key,
    this.controller,
    this.onChanged,
    this.side = BorderSide.none,
  }) : super(key: key);
  final ImagePickerInputController? controller;
  final ValueChanged<File?>? onChanged;
  final BorderSide side;

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  late ImagePickerInputController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? ImagePickerInputController();
    controller.addListener(() {
      widget.onChanged?.call(controller.value);
    });
  }

  @override
  void didUpdateWidget(covariant ImagePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      controller = widget.controller ?? ImagePickerInputController();
      controller.addListener(() {
        widget.onChanged?.call(controller.value);
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () async {
        final image =
            await ImagePicker().pickImage(source: ImageSource.gallery);

        if (image == null) return;
        controller.file = File(image.path);
      },
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            side: widget.side,
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, imageFile, child) =>
              imageFile == null ? child! : Image.file(imageFile),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text('Pick image', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePickerInputController extends ValueNotifier<File?> {
  ImagePickerInputController({File? initialValue}) : super(initialValue);

  String get fileName => value?.path.split('/').last ?? '';

  set file(File newValue) {
    if (newValue.path == value?.path) return;

    value = newValue;
    notifyListeners();
  }
}
