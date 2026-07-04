import { Alert, Linking } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { ImageManipulator, SaveFormat } from 'expo-image-manipulator';

const PICKER_OPTIONS: ImagePicker.ImagePickerOptions = {
  mediaTypes: ['images'],
  quality: 1,
  allowsEditing: true,
};

const MAX_DIMENSION = 1024;
const COMPRESS_QUALITY = 0.6;

async function resizeToBase64(asset: ImagePicker.ImagePickerAsset): Promise<string> {
  const longSide = Math.max(asset.width, asset.height);
  let context = ImageManipulator.manipulate(asset.uri);

  if (longSide > MAX_DIMENSION) {
    const isLandscape = asset.width >= asset.height;
    context = isLandscape
      ? context.resize({ width: MAX_DIMENSION })
      : context.resize({ height: MAX_DIMENSION });
  }

  const rendered = await context.renderAsync();
  const result = await rendered.saveAsync({
    compress: COMPRESS_QUALITY,
    format: SaveFormat.JPEG,
    base64: true,
  });

  if (!result.base64) {
    throw new Error('이미지 처리에 실패했습니다.');
  }

  return result.base64;
}

async function pickerResultToBase64(result: ImagePicker.ImagePickerResult): Promise<string | null> {
  const asset = result.assets?.[0];
  if (result.canceled || !asset) {
    return null;
  }
  return resizeToBase64(asset);
}

async function ensureGranted(
  permission: ImagePicker.PermissionResponse,
  deniedMessage: string,
): Promise<void> {
  switch (permission.status) {
    case ImagePicker.PermissionStatus.GRANTED:
      return;
    case ImagePicker.PermissionStatus.DENIED:
      if (!permission.canAskAgain) {
        Alert.alert('권한이 필요합니다', `${deniedMessage} 설정에서 권한을 허용해주세요.`, [
          { text: '취소', style: 'cancel' },
          { text: '설정으로 이동', onPress: () => Linking.openSettings() },
        ]);
      }
      throw new Error(deniedMessage);
    case ImagePicker.PermissionStatus.UNDETERMINED:
    default:
      throw new Error(deniedMessage);
  }
}

export async function takePhoto(): Promise<string | null> {
  const permission = await ImagePicker.requestCameraPermissionsAsync();
  await ensureGranted(permission, '카메라 권한이 필요합니다.');

  const result = await ImagePicker.launchCameraAsync(PICKER_OPTIONS);
  return pickerResultToBase64(result);
}

export async function pickPhotoFromLibrary(): Promise<string | null> {
  const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
  await ensureGranted(permission, '사진 라이브러리 권한이 필요합니다.');

  const result = await ImagePicker.launchImageLibraryAsync(PICKER_OPTIONS);
  return pickerResultToBase64(result);
}
