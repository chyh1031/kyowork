import * as ImagePicker from 'expo-image-picker';

const PICKER_OPTIONS: ImagePicker.ImagePickerOptions = {
  mediaTypes: ['images'],
  quality: 0.6,
  base64: true,
  allowsEditing: true,
};

async function toBase64(result: ImagePicker.ImagePickerResult): Promise<string | null> {
  if (result.canceled || !result.assets[0]?.base64) {
    return null;
  }
  return result.assets[0].base64;
}

export async function takePhoto(): Promise<string | null> {
  const permission = await ImagePicker.requestCameraPermissionsAsync();
  if (!permission.granted) {
    throw new Error('카메라 권한이 필요합니다.');
  }

  const result = await ImagePicker.launchCameraAsync(PICKER_OPTIONS);
  return toBase64(result);
}

export async function pickPhotoFromLibrary(): Promise<string | null> {
  const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
  if (!permission.granted) {
    throw new Error('사진 라이브러리 권한이 필요합니다.');
  }

  const result = await ImagePicker.launchImageLibraryAsync(PICKER_OPTIONS);
  return toBase64(result);
}
