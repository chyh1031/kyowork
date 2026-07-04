import { env } from '@/lib/env';
import { generateListingResponseSchema, type Listing } from '@/schemas/listing';

export async function generateListing(photoBase64: string): Promise<Listing> {
  const response = await fetch(`${env.apiBaseUrl}/api/generate`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ photoBase64 }),
  });

  if (!response.ok) {
    throw new Error(`AI 생성 요청 실패 (${response.status})`);
  }

  const json = await response.json();
  const parsed = generateListingResponseSchema.parse(json);

  return parsed.listing;
}
