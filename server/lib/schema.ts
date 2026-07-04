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

export const generateRequestSchema = z.object({
  photoBase64: z.string().min(1),
});
