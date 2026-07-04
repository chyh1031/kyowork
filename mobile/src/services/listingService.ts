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

export type SavedListing = {
  id: string;
  title: string;
  price: number;
  status: 'active' | 'sold' | 'archived';
  createdAt: string;
};

export async function fetchMyListings(): Promise<SavedListing[]> {
  const session = await getSession();
  if (!session) {
    throw new LoginRequiredError();
  }

  const { data, error } = await supabase
    .from('listings')
    .select('id, title, price, status, created_at')
    .order('created_at', { ascending: false });

  if (error) {
    throw new Error(error.message);
  }

  return (data ?? []).map((row) => ({
    id: row.id as string,
    title: row.title as string,
    price: row.price as number,
    status: row.status as SavedListing['status'],
    createdAt: row.created_at as string,
  }));
}

export async function submitSoldFeedback(listingId: string, soldPrice: number): Promise<void> {
  const session = await getSession();
  if (!session) {
    throw new LoginRequiredError();
  }

  const { error: feedbackError } = await supabase
    .from('listing_feedback')
    .insert({ listing_id: listingId, sold_price: soldPrice });

  if (feedbackError) {
    throw new Error(feedbackError.message);
  }

  const { error: updateError } = await supabase
    .from('listings')
    .update({ status: 'sold' })
    .eq('id', listingId);

  if (updateError) {
    throw new Error(updateError.message);
  }
}
