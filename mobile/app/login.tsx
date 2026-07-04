import { useState } from 'react';
import { router } from 'expo-router';
import {
  ActivityIndicator,
  Alert,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

import { sendLoginCode, verifyLoginCode } from '@/lib/auth';

type Step = 'email' | 'code';

export default function Login() {
  const [step, setStep] = useState<Step>('email');
  const [email, setEmail] = useState('');
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSendCode() {
    if (!email.trim()) return;

    setLoading(true);
    try {
      await sendLoginCode(email.trim());
      setStep('code');
    } catch (error) {
      Alert.alert('오류', error instanceof Error ? error.message : '코드 발송에 실패했습니다.');
    } finally {
      setLoading(false);
    }
  }

  async function handleVerifyCode() {
    if (!code.trim()) return;

    setLoading(true);
    try {
      await verifyLoginCode(email.trim(), code.trim());
      if (router.canGoBack()) {
        router.back();
      } else {
        router.replace('/capture');
      }
    } catch (error) {
      Alert.alert('오류', error instanceof Error ? error.message : '로그인에 실패했습니다.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>로그인</Text>

      {step === 'email' ? (
        <>
          <Text style={styles.body}>이메일로 받은 인증 코드로 로그인해요.</Text>
          <TextInput
            style={styles.input}
            placeholder="이메일 주소"
            autoCapitalize="none"
            keyboardType="email-address"
            value={email}
            onChangeText={setEmail}
          />
          <Pressable style={styles.button} onPress={handleSendCode} disabled={loading}>
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.buttonText}>코드 받기</Text>
            )}
          </Pressable>
        </>
      ) : (
        <>
          <Text style={styles.body}>{email}로 발송된 6자리 코드를 입력해주세요.</Text>
          <TextInput
            style={styles.input}
            placeholder="인증 코드"
            keyboardType="number-pad"
            value={code}
            onChangeText={setCode}
          />
          <Pressable style={styles.button} onPress={handleVerifyCode} disabled={loading}>
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.buttonText}>확인</Text>
            )}
          </Pressable>
          <Pressable style={styles.secondaryButton} onPress={() => setStep('email')}>
            <Text style={styles.secondaryButtonText}>이메일 다시 입력</Text>
          </Pressable>
        </>
      )}
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
    marginBottom: 8,
  },
  body: {
    fontSize: 14,
    color: '#555',
    marginBottom: 8,
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
  secondaryButton: {
    paddingVertical: 12,
  },
  secondaryButtonText: {
    color: '#555',
    fontSize: 14,
    textAlign: 'center',
  },
});
