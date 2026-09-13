import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class Select1 {
  // 1. Checkbox metodu
  static Widget checkbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  // 2. Switch metodu
  static Widget switchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  // 3. Radio metodu
  static Widget radio<T>({
    required String label,
    required T value,
    required T? groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }

  // 4. Slider metodu
  static Widget slider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
    String? label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(label),
          ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // 5. DropdownButtonFormField metodu
  static Widget dropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  // 6. TextFormField metodu
  static Widget textField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  // 7. DatePicker metodu
  static Widget datePicker({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        selectedDate != null
            ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
            : "Tarih Seçilmedi",
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
    );
  }

  // 8. TimePicker metodu
  static Widget timePicker({
    required BuildContext context,
    required String label,
    required TimeOfDay? selectedTime,
    required ValueChanged<TimeOfDay> onTimeSelected,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        selectedTime != null
            ? selectedTime.format(context)
            : "Saat Seçilmedi",
      ),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
    );
  }

  // 9. DateTimePicker metodu
  static Widget dateTimePicker({
    required BuildContext context,
    required String label,
    required DateTime? selectedDateTime,
    required ValueChanged<DateTime> onDateTimeSelected,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        selectedDateTime != null
            ? "${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} - ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}"
            : "Tarih ve Saat Seçilmedi",
      ),
      trailing: const Icon(Icons.event_available),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDateTime ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null && context.mounted) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
          );
          if (pickedTime != null) {
            final DateTime fullDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            onDateTimeSelected(fullDateTime);
          }
        }
      },
    );
  }

  // 10. ImagePicker metodu
  static Widget imagePicker({
    required String label,
    required File? selectedImage,
    required ValueChanged<File?> onImageSelected,
    ImageSource source = ImageSource.gallery,
  }) {
    final ImagePicker picker = ImagePicker();

    return ListTile(
      title: Text(label),
      subtitle: Text(
        selectedImage != null
            ? selectedImage.path.split('/').last
            : "Resim Seçilmedi",
      ),
      leading: selectedImage != null
          ? Image.file(selectedImage, width: 40, height: 40, fit: BoxFit.cover)
          : const Icon(Icons.image),
      trailing: const Icon(Icons.add_a_photo),
      onTap: () async {
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          onImageSelected(File(image.path));
        }
      },
    );
  }

  // 11. FilePicker metodu 
  static Widget filePicker({
    required String label,
    required File? selectedFile,
    required ValueChanged<File?> onFileSelected,
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        selectedFile != null
            ? selectedFile.path.split('/').last
            : "Dosya Seçilmedi",
      ),
      leading: const Icon(Icons.insert_drive_file),
      trailing: const Icon(Icons.attach_file),
      onTap: () async {
        final result = await FilePicker.pickFiles(
          type: type,
          allowedExtensions: allowedExtensions,
        );

        if (result.single.path != null) {
          onFileSelected(File(result.single.path!));
        }
      },
    );
  }
}