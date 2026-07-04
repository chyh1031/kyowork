import { env } from '@/lib/env';
import { generateListingResponseSchema, type Listing } from '@/schemas/listing';

const TIMEOUT_MS = 15000;

export async function generateListing(photoBase64: string): Promise<Listing> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS);

  try {
    const response = await fetch(`${env.apiBaseUrl}/api/generate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ photoBase64 }),
      signal: controller.signal,
    });

    if (!response.ok) {
      throw new Error(`AI 생성 요청 실패 (${response.status})`);
    }

    const json = await response.json();
    const parsed = generateListingResponseSchema.parse(json);

    return parsed.listing;
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      throw new Error('요청 시간이 초과되었습니다. 다시 시도해주세요.');
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}
