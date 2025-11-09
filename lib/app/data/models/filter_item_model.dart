import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum FilterType {
  dropdown,
  checkbox,
  text,
  number,
  date,
  radio,
  singleCheckbox
}

class FilterItem<T> {
  final String label;
  final FilterType type;
  final List<DropdownMenuItem<T>>? menuItems;
  final List<T>? options;
  final T? initialValue;

  final RxString? error;

  final TextEditingController? controller;

  final Rx<T?>? value;

  FilterItem({
    required this.label,
    required this.type,
    this.menuItems,
    this.options,
    this.initialValue,
    this.error,
    this.controller,
    this.value,
  });

  static InputDecoration inputDecoration(
      String hint, RxString? error, BuildContext context) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: hint,
      hintStyle: const TextStyle(fontWeight: FontWeight.normal),
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.dividerColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
      ),
      errorText: error?.value.isEmpty ?? true ? null : error?.value,
    );
  }

  Widget toWidget(BuildContext context, void Function(T? value) onChanged) {
    final theme = Theme.of(context);

    switch (type) {
      /// DROPDOWN
      case FilterType.dropdown:
        return Obx(() {
          final currentValue = value?.value ?? initialValue;
          final validItems =
              menuItems?.map((e) => e.value).toList() ?? options ?? [];

          final safeValue =
              validItems.contains(currentValue) ? currentValue : null;

          return DropdownButtonFormField<T>(
            decoration: inputDecoration(label, error, context),
            initialValue: safeValue,
            items: menuItems ??
                validItems
                    .map((opt) => DropdownMenuItem<T>(
                          value: opt,
                          child: Text(opt.toString()),
                        ))
                    .toList(),
            onChanged: (v) {
              value?.value = v;
              error?.value = '';
              onChanged(v);
            },
          );
        });

      /// CHECKBOX (multi-select)
      case FilterType.checkbox:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Obx(() {
              final selected = value?.value is Iterable
                  ? List<T>.from(value!.value as Iterable)
                  : <T>[];

              return Column(
                children: (options ?? []).map((opt) {
                  return CheckboxListTile(
                    title: Text(opt.toString()),
                    value: selected.contains(opt),
                    onChanged: (val) {
                      if (val == true) {
                        selected.add(opt);
                      } else {
                        selected.remove(opt);
                      }
                      value?.value = selected as T;
                      error?.value = '';
                      onChanged(value?.value);
                    },
                  );
                }).toList(),
              );
            }),
            if (error != null && error!.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(error!.value,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        );

      case FilterType.singleCheckbox:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final checked =
                  (value?.value is bool) ? value!.value as bool : false;

              return CheckboxListTile(
                title: Text(label,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                value: checked,
                controlAffinity: ListTileControlAffinity.trailing,
                onChanged: (val) {
                  value?.value = val as T;
                  error?.value = '';
                  onChanged(value?.value);
                },
              );
            }),
            if (error != null && error!.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(error!.value,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        );

      /// RADIO (single choice)
      case FilterType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Obx(() => Column(
                  children: (options ?? []).map((opt) {
                    return RadioListTile<T>(
                      title: Text(opt.toString()),
                      value: opt,
                      groupValue: value?.value,
                      onChanged: (v) {
                        value?.value = v;
                        error?.value = '';
                        onChanged(v);
                      },
                    );
                  }).toList(),
                )),
          ],
        );

      /// TEXT INPUT
      case FilterType.text:
        return Obx(() => TextField(
              controller: controller,
              decoration: inputDecoration(label, error, context),
              onChanged: (v) {
                value?.value = v as T;
                error?.value = '';
                onChanged(value?.value);
              },
            ));

      /// NUMBER INPUT
      case FilterType.number:
        return TextField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(8),
            FilteringTextInputFormatter.digitsOnly,
          ],
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: inputDecoration(label, error, context),
          onChanged: (v) {
            T? numVal;
            if (T == int) {
              numVal = int.tryParse(v) as T?;
            } else if (T == double) {
              numVal = double.tryParse(v) as T?;
            }
            value?.value = numVal;
            error?.value = '';
            onChanged(numVal);
          },
        );

      /// DATE PICKER
      case FilterType.date:
        return GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: value?.value as DateTime? ?? DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              value?.value = picked as T;
              controller?.text = "${picked.year}-${picked.month}-${picked.day}";
              error?.value = '';
              onChanged(value?.value);
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              readOnly: true,
              decoration: inputDecoration(label, error, context).copyWith(
                suffixIcon: const Icon(Icons.date_range),
              ),
            ),
          ),
        );
    }
  }
}
