import { Pressable, Text } from 'react-native';
import { router, Stack } from 'expo-router';

function MyPageHeaderButton() {
  return (
    <Pressable onPress={() => router.push('/mypage')} hitSlop={8}>
      <Text style={{ fontSize: 14, fontWeight: '600' }}>마이페이지</Text>
    </Pressable>
  );
}

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'MiddlePoint' }} />
      <Stack.Screen
        name="capture"
        options={{ title: '판매글 만들기', headerRight: MyPageHeaderButton }}
      />
      <Stack.Screen name="mypage" options={{ title: '마이페이지' }} />
      <Stack.Screen name="login" options={{ title: '로그인' }} />
      <Stack.Screen name="feedback" options={{ title: '판매완료 등록' }} />
    </Stack>
  );
}
