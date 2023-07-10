import 'package:flutter/material.dart';

enum RadioInput {
  text('Text'),
  widget('Widget'),
  flutter('Flutter');

  const RadioInput(this.title);

  final String title;
}

class RadioButtonFormGroup extends FormField<RadioInput?> {
  RadioButtonFormGroup({
    super.key,
    RadioGroupInputController? controller,
    ValueChanged<RadioInput?>? onChanged,
    super.validator,
    super.autovalidateMode,
  }) : super(
          initialValue: controller?.value,
          builder: (state) {
            void onChangedHandler(RadioInput? value) {
              state.didChange(value);
              if (onChanged != null) {
                onChanged(value);
              }
            }

            return UnmanagedRestorationScope(
              bucket: state.bucket,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RadioButtonGroup(
                      controller: controller,
                      onChanged: onChangedHandler,
                      fillColor: state.hasError ? Colors.red : null,
                    ),
                    if (state.hasError) ...[
                      Text(
                        state.errorText!,
                        style: const TextStyle(fontSize: 15, color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
}

class RadioButtonGroup extends StatefulWidget {
  const RadioButtonGroup({
    Key? key,
    this.controller,
    this.onChanged,
    this.fillColor,
  }) : super(key: key);

  final RadioGroupInputController? controller;
  final ValueChanged<RadioInput?>? onChanged;
  final Color? fillColor;

  @override
  State<RadioButtonGroup> createState() => _RadioButtonGroupState();
}

class _RadioButtonGroupState extends State<RadioButtonGroup> {
  late RadioGroupInputController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? RadioGroupInputController();

    controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant RadioButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      controller.removeListener(_handleControllerChanged);
      controller = widget.controller ?? RadioGroupInputController();

      controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    widget.onChanged?.call(controller.value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (_, radioGroupValue, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: RadioInput.values
            .map((e) => RadioListTile(
                  value: e,
                  groupValue: radioGroupValue,
                  fillColor: switch (widget.fillColor) {
                    final color? => MaterialStateProperty.all(color),
                    _ => null,
                  },
                  title: Text(e.title),
                  onChanged: (value) {
                    controller.input = value;
                  },
                ))
            .toList(),
      ),
    );
  }
}

class RadioGroupInputController extends ValueNotifier<RadioInput?> {
  RadioGroupInputController({RadioInput? initialValue}) : super(initialValue);

  String get title => value?.title ?? '';

  set input(RadioInput? newInput) {
    if (newInput == value) null;
    value = newInput;

    notifyListeners();
  }
}
