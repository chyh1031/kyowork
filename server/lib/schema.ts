import { z } from 'zod';

export const listingSchema = z.object({
  title: z.string().min(1),
  description: z.string().min(1),
  price: z.number().int().nonnegative(),
  priceRangeMin: z.number().int().nonnegative(),
  priceRangeMax: z.number().int().nonnegative(),
  category: z.string().min(1),
});

export type Listing = z.infer<typeof listingSchema>;

// base64 문자열 기준 6MB 상한 (원본 이미지 기준 약 4.3MB)
const MAX_PHOTO_BASE64_LENGTH = 6 * 1024 * 1024;

export const generateRequestSchema = z.object({
  photoBase64: z
    .string()
    .min(1)
    .max(MAX_PHOTO_BASE64_LENGTH, `photoBase64는 최대 ${MAX_PHOTO_BASE64_LENGTH}자까지 허용됩니다.`),
});
