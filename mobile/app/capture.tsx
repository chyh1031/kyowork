import { useRef, useState } from 'react';
import { router } from 'expo-router';
import { ActivityIndicator, Alert, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import ShareCard from '@/components/ShareCard';
import { generateListing } from '@/services/aiService';
import { copyListingToClipboard, formatListingForShare } from '@/services/clipboardService';
import { LoginRequiredError, saveListing } from '@/services/listingService';
import { pickPhotoFromLibrary, takePhoto } from '@/services/photoService';
import { shareCardFromRef } from '@/services/shareCardService';
import type { Listing } from '@/schemas/listing';

type Status = 'idle' | 'loading' | 'result' | 'error';
type PickFn = () => Promise<string | null>;

export default function Capture() {
  const [status, setStatus] = useState<Status>('idle');
  const [listing, setListing] = useState<Listing | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [sharingCard, setSharingCard] = useState(false);
  const lastPickRef = useRef<PickFn | null>(null);
  const cardRef = useRef<View>(null);

  async function handlePhoto(pick: PickFn) {
    lastPickRef.current = pick;

    try {
      const base64 = await pick();
      if (!base64) return;

      setStatus('loading');
      const result = await generateListing(base64);
      setListing(result);
      setStatus('result');
    } catch (error) {
      setErrorMessage(error instanceof Error ? error.message : '알 수 없는 오류가 발생했습니다.');
      setStatus('error');
    }
  }

  async function handleCopy() {
    if (!listing) return;
    await copyListingToClipboard(listing);
    Alert.alert('복사 완료', '판매글이 클립보드에 복사되었습니다.');
  }

  async function handleSave() {
    if (!listing) return;

    setSaving(true);
    try {
      await saveListing(listing);
      Alert.alert('저장 완료', '등록이력에 저장됐어요.');
    } catch (error) {
      if (error instanceof LoginRequiredError) {
        Alert.alert('로그인이 필요해요', '등록이력을 저장하려면 로그인해주세요.', [
          { text: '취소', style: 'cancel' },
          { text: '로그인하기', onPress: () => router.push('/login') },
        ]);
      } else {
        Alert.alert('오류', error instanceof Error ? error.message : '저장에 실패했습니다.');
      }
    } finally {
      setSaving(false);
    }
  }

  async function handleShareCard() {
    setSharingCard(true);
    try {
      await shareCardFromRef(cardRef);
    } catch (error) {
      Alert.alert('오류', error instanceof Error ? error.message : '카드 공유에 실패했습니다.');
    } finally {
      setSharingCard(false);
    }
  }

  function retry() {
    const pick = lastPickRef.current;
    setErrorMessage(null);
    setStatus('idle');
    if (pick) {
      handlePhoto(pick);
    }
  }

  function reset() {
    setListing(null);
    setErrorMessage(null);
    setStatus('idle');
  }

  if (status === 'loading') {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" />
        <Text style={styles.hint}>AI가 판매글을 생성하고 있어요...</Text>
      </View>
    );
  }

  if (status === 'error') {
    return (
      <View style={styles.center}>
        <Text style={styles.hint}>{errorMessage}</Text>
        <Pressable style={styles.button} onPress={retry}>
          <Text style={styles.buttonText}>다시 시도</Text>
        </Pressable>
        <Pressable style={styles.secondaryButton} onPress={reset}>
          <Text style={styles.secondaryButtonText}>처음으로</Text>
        </Pressable>
      </View>
    );
  }

  if (status === 'result' && listing) {
    return (
      <ScrollView contentContainerStyle={styles.container}>
        <Text style={styles.label}>제목</Text>
        <Text style={styles.value}>{listing.title}</Text>

        <Text style={styles.label}>설명</Text>
        <Text style={styles.value}>{listing.description}</Text>

        <Text style={styles.label}>예상 가격</Text>
        <Text style={styles.value}>{listing.price.toLocaleString('ko-KR')}원</Text>
        <Text style={styles.caption}>
          AI가 추천한 참고 가격이며 실제 거래가와 다를 수 있어요 ({listing.priceRangeMin.toLocaleString('ko-KR')}
          ~{listing.priceRangeMax.toLocaleString('ko-KR')}원)
        </Text>

        <Text style={styles.preview}>{formatListingForShare(listing)}</Text>

        <Pressable style={styles.button} onPress={handleCopy}>
          <Text style={styles.buttonText}>복사하기</Text>
        </Pressable>
        <Pressable style={styles.secondaryButton} onPress={handleSave} disabled={saving}>
          {saving ? (
            <ActivityIndicator />
          ) : (
            <Text style={styles.secondaryButtonText}>등록이력에 저장</Text>
          )}
        </Pressable>
        <Pressable style={styles.secondaryButton} onPress={handleShareCard} disabled={sharingCard}>
          {sharingCard ? (
            <ActivityIndicator />
          ) : (
            <Text style={styles.secondaryButtonText}>카드 이미지로 공유</Text>
          )}
        </Pressable>
        <Pressable style={styles.secondaryButton} onPress={reset}>
          <Text style={styles.secondaryButtonText}>다시 만들기</Text>
        </Pressable>

        <View style={styles.offscreen} pointerEvents="none">
          <ShareCard ref={cardRef} listing={listing} />
        </View>
      </ScrollView>
    );
  }

  return (
    <View style={styles.center}>
      <Pressable style={styles.button} onPress={() => handlePhoto(takePhoto)}>
        <Text style={styles.buttonText}>사진 촬영</Text>
      </Pressable>
      <Pressable style={styles.secondaryButton} onPress={() => handlePhoto(pickPhotoFromLibrary)}>
        <Text style={styles.secondaryButtonText}>앨범에서 선택</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
    padding: 24,
  },
  container: {
    padding: 24,
    gap: 8,
  },
  offscreen: {
    position: 'absolute',
    top: 0,
    left: -9999,
  },
  hint: {
    color: '#555',
  },
  label: {
    marginTop: 12,
    fontSize: 13,
    color: '#888',
  },
  value: {
    fontSize: 16,
  },
  caption: {
    marginTop: 4,
    fontSize: 12,
    color: '#999',
  },
  preview: {
    marginTop: 16,
    padding: 12,
    backgroundColor: '#f4f4f4',
    borderRadius: 8,
    fontSize: 13,
    color: '#333',
  },
  button: {
    backgroundColor: '#111',
    paddingVertical: 14,
    paddingHorizontal: 32,
    borderRadius: 999,
    marginTop: 16,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  secondaryButton: {
    paddingVertical: 14,
    paddingHorizontal: 32,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: '#111',
  },
  secondaryButtonText: {
    color: '#111',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
});
