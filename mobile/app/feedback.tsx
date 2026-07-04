import { useState } from 'react';
import { router, useLocalSearchParams } from 'expo-router';
import {
  ActivityIndicator,
  Alert,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

import { submitSoldFeedback } from '@/services/listingService';

export default function SoldFeedback() {
  const { listingId, title } = useLocalSearchParams<{ listingId: string; title?: string }>();
  const [soldPrice, setSoldPrice] = useState('');
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit() {
    const price = Number(soldPrice);
    if (!listingId || !Number.isFinite(price) || price < 0) {
      Alert.alert('오류', '실제 판매 가격을 정확히 입력해주세요.');
      return;
    }

    setSubmitting(true);
    try {
      await submitSoldFeedback(listingId, price);
      Alert.alert('완료', '판매완료 정보가 저장됐어요. 감사합니다!');
      router.back();
    } catch (error) {
      Alert.alert('오류', error instanceof Error ? error.message : '저장에 실패했습니다.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>판매완료 등록</Text>
      {title ? <Text style={styles.body}>{title}</Text> : null}

      <Text style={styles.label}>실제 판매 가격 (원)</Text>
      <TextInput
        style={styles.input}
        placeholder="예: 550000"
        keyboardType="number-pad"
        value={soldPrice}
        onChangeText={setSoldPrice}
      />

      <Pressable style={styles.button} onPress={handleSubmit} disabled={submitting}>
        {submitting ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>저장</Text>
        )}
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: 24,
    gap: 12,
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
  },
  body: {
    fontSize: 14,
    color: '#555',
  },
  label: {
    fontSize: 13,
    color: '#888',
    marginTop: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 14,
    paddingVertical: 12,
    fontSize: 16,
  },
  button: {
    backgroundColor: '#111',
    paddingVertical: 14,
    borderRadius: 999,
    marginTop: 8,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
});
