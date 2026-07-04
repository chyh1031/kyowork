import Anthropic from '@anthropic-ai/sdk';
import { listingSchema, type Listing } from './schema';

const MODEL = process.env.ANTHROPIC_MODEL ?? 'claude-sonnet-5';

let client: Anthropic | null = null;

function getClient(): Anthropic {
  if (!client) {
    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) {
      throw new Error('Missing ANTHROPIC_API_KEY environment variable');
    }
    client = new Anthropic({ apiKey });
  }
  return client;
}

const LISTING_TOOL: Anthropic.Tool = {
  name: 'submit_listing',
  description: '사진을 분석해 중고거래 판매글 정보를 제출합니다.',
  input_schema: {
    type: 'object',
    properties: {
      title: { type: 'string', description: '판매글 제목 (30자 이내)' },
      description: { type: 'string', description: '물건 상태와 특징을 설명하는 판매글 본문' },
      category: { type: 'string', description: '물건 카테고리 (예: 가전, 가구, 의류)' },
      price: { type: 'integer', description: '추천 판매가 (원)' },
      priceRangeMin: { type: 'integer', description: '적정가 하한 (원)' },
      priceRangeMax: { type: 'integer', description: '적정가 상한 (원)' },
    },
    required: ['title', 'description', 'category', 'price', 'priceRangeMin', 'priceRangeMax'],
  },
};

export async function generateListingFromPhoto(
  photoBase64: string,
  mediaType: 'image/jpeg' | 'image/png' = 'image/jpeg',
): Promise<Listing> {
  const anthropic = getClient();

  const message = await anthropic.messages.create({
    model: MODEL,
    max_tokens: 1024,
    system:
      '당신은 한국 중고거래 플랫폼(당근마켓, 번개장터)의 판매글 작성을 돕는 어시스턴트입니다. ' +
      '사진 속 물건을 분석해 매력적인 제목, 상세 설명, 합리적인 중고 시세를 제안하세요. ' +
      '가격은 한국 중고 시세 기준 원화로 제시합니다.',
    messages: [
      {
        role: 'user',
        content: [
          { type: 'image', source: { type: 'base64', media_type: mediaType, data: photoBase64 } },
          { type: 'text', text: '이 사진 속 물건으로 중고거래 판매글을 작성해줘.' },
        ],
      },
    ],
    tools: [LISTING_TOOL],
    tool_choice: { type: 'tool', name: LISTING_TOOL.name },
  });

  const toolUse = message.content.find((block) => block.type === 'tool_use');
  if (!toolUse || toolUse.type !== 'tool_use') {
    throw new Error('AI 응답에서 판매글 정보를 찾을 수 없습니다.');
  }

  return listingSchema.parse(toolUse.input);
}
