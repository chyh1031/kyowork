import * as Clipboard from 'expo-clipboard';
import type { Listing } from '@/schemas/listing';

export function formatListingForShare(listing: Listing): string {
  return `${listing.title}\n\n${listing.description}\n\n가격: ${listing.price.toLocaleString('ko-KR')}원`;
}

export async function copyListingToClipboard(listing: Listing): Promise<void> {
  await Clipboard.setStringAsync(formatListingForShare(listing));
}
