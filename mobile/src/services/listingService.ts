import { getSession } from '@/lib/auth';
import { supabase } from '@/lib/supabase';
import type { Listing } from '@/schemas/listing';

export class LoginRequiredError extends Error {
  constructor() {
    super('로그인이 필요합니다.');
    this.name = 'LoginRequiredError';
  }
}

export async function saveListing(listing: Listing): Promise<void> {
  const session = await getSession();
  if (!session) {
    throw new LoginRequiredError();
  }

  const { error } = await supabase.from('listings').insert({
    user_id: session.user.id,
    title: listing.title,
    description: listing.description,
    category: listing.category,
    price: listing.price,
    price_range_min: listing.priceRangeMin,
    price_range_max: listing.priceRangeMax,
  });

  if (error) {
    throw new Error(error.message);
  }
}
