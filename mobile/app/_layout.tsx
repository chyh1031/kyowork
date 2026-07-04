import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'MiddlePoint' }} />
      <Stack.Screen name="capture" options={{ title: '판매글 만들기' }} />
    </Stack>
  );
}
