import { beforeEach, describe, expect, it, vi } from 'vitest';

const store = new Map<string, string>();

vi.mock('@react-native-async-storage/async-storage', () => ({
  default: {
    getItem: vi.fn((key: string) => Promise.resolve(store.get(key) ?? null)),
    setItem: vi.fn((key: string, value: string) => {
      store.set(key, value);
      return Promise.resolve();
    }),
  },
}));

const { isOnboardingComplete, markOnboardingComplete } = await import('./onboarding');

beforeEach(() => {
  store.clear();
});

describe('onboarding storage', () => {
  it('is not complete before anything is stored', async () => {
    expect(await isOnboardingComplete()).toBe(false);
  });

  it('is complete after marking it complete', async () => {
    await markOnboardingComplete();
    expect(await isOnboardingComplete()).toBe(true);
  });
});
