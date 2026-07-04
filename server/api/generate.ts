import type { VercelRequest, VercelResponse } from '@vercel/node';
import { generateRequestSchema } from '../lib/schema';
import { generateListingFromPhoto } from '../lib/anthropic';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const parsedBody = generateRequestSchema.safeParse(req.body);
  if (!parsedBody.success) {
    return res.status(400).json({ error: 'Invalid request body', details: parsedBody.error.flatten() });
  }

  try {
    const listing = await generateListingFromPhoto(parsedBody.data.photoBase64);
    return res.status(200).json({ listing });
  } catch (error) {
    console.error('generateListingFromPhoto failed', error);
    return res.status(502).json({ error: '판매글 생성에 실패했습니다. 잠시 후 다시 시도해주세요.' });
  }
}
