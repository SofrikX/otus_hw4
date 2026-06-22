import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const allowedPetPhotoExtensions = {'jpg', 'jpeg', 'png', 'webp'};
const allowedPetPhotoContentTypes = {
  'image/jpeg',
  'image/png',
  'image/webp',
};
const maxPetPhotoSizeBytes = 5 * 1024 * 1024;

final petPhotoPickerProvider = Provider<PetPhotoPicker>((ref) {
  return const FilePickerPetPhotoPicker();
});

abstract class PetPhotoPicker {
  Future<PickedPetPhoto?> pickPhoto();
}

class PickedPetPhoto {
  const PickedPetPhoto({
    required this.name,
    required this.bytes,
    required this.contentType,
  });

  final String name;
  final Uint8List bytes;
  final String contentType;

  int get sizeBytes => bytes.lengthInBytes;
}

class FilePickerPetPhotoPicker implements PetPhotoPicker {
  const FilePickerPetPhotoPicker();

  @override
  Future<PickedPetPhoto?> pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedPetPhotoExtensions.toList(growable: false),
      allowMultiple: false,
      withData: true,
    );

    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) {
      return null;
    }

    final contentType = _contentTypeFromExtension(file.extension);
    return PickedPetPhoto(
      name: file.name,
      bytes: bytes,
      contentType: contentType,
    );
  }

  String _contentTypeFromExtension(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}

class PetPhotoValidationException implements Exception {
  const PetPhotoValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

void validatePetPhoto(PickedPetPhoto photo) {
  final extension = photo.name.split('.').last.toLowerCase();
  if (!allowedPetPhotoExtensions.contains(extension) ||
      !allowedPetPhotoContentTypes.contains(photo.contentType)) {
    throw const PetPhotoValidationException(
      'Можно загрузить только JPG, PNG или WebP.',
    );
  }

  if (photo.sizeBytes <= 0) {
    throw const PetPhotoValidationException(
      'Файл пустой. Выберите другое изображение.',
    );
  }

  if (photo.sizeBytes > maxPetPhotoSizeBytes) {
    throw const PetPhotoValidationException(
      'Фото должно быть не больше 5 МБ.',
    );
  }
}
