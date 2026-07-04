import { router } from 'expo-router';
import { StyleSheet, Text, View, Pressable } from 'react-native';

export default function Onboarding() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>사진 한 장으로 판매글 완성</Text>
      <Text style={styles.body}>
        물건 사진을 찍거나 앨범에서 선택하면 AI가 제목, 설명, 가격을 자동으로 만들어드려요.
      </Text>
      <Pressable style={styles.button} onPress={() => router.push('/capture')}>
        <Text style={styles.buttonText}>시작하기</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    gap: 16,
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
    textAlign: 'center',
  },
  body: {
    fontSize: 15,
    color: '#555',
    textAlign: 'center',
  },
  button: {
    marginTop: 8,
    backgroundColor: '#111',
    paddingVertical: 14,
    paddingHorizontal: 32,
    borderRadius: 999,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
