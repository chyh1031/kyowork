import Constants from 'expo-constants';

function readEnv(key: string): string {
  const value =
    process.env[key] ?? (Constants.expoConfig?.extra?.[key] as string | undefined);

  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }

  return value;
}

export const env = {
  get apiBaseUrl() {
    return readEnv('EXPO_PUBLIC_API_BASE_URL');
  },
  get supabaseUrl() {
    return readEnv('EXPO_PUBLIC_SUPABASE_URL');
  },
  get supabaseAnonKey() {
    return readEnv('EXPO_PUBLIC_SUPABASE_ANON_KEY');
  },
};
