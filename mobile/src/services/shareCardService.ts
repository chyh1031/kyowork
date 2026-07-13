import type { RefObject } from 'react';
import type { View } from 'react-native';
import { captureRef } from 'react-native-view-shot';
import * as Sharing from 'expo-sharing';

export async function shareCardFromRef(cardRef: RefObject<View | null>): Promise<void> {
  if (!cardRef.current) {
    throw new Error('카드를 아직 준비하지 못했습니다.');
  }

  const uri = await captureRef(cardRef, { format: 'png', quality: 1 });

  const available = await Sharing.isAvailableAsync();
  if (!available) {
    throw new Error('이 기기에서는 공유하기를 사용할 수 없습니다.');
  }

  await Sharing.shareAsync(uri, { mimeType: 'image/png' });
}
