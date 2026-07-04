import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'MiddlePoint' }} />
      <Stack.Screen name="capture" options={{ title: '판매글 만들기' }} />
      <Stack.Screen name="mypage" options={{ title: '마이페이지' }} />
      <Stack.Screen name="login" options={{ title: '로그인' }} />
      <Stack.Screen name="feedback" options={{ title: '판매완료 등록' }} />
    </Stack>
  );
}
