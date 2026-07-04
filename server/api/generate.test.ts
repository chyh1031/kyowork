import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { VercelRequest, VercelResponse } from '@vercel/node';

const createMock = vi.fn();

vi.mock('@anthropic-ai/sdk', () => ({
  default: vi.fn().mockImplementation(function AnthropicMock() {
    return { messages: { create: createMock } };
  }),
}));

const { default: handler } = await import('./generate');

function createRes() {
  const res = {
    statusCode: 0,
    body: undefined as unknown,
    headers: {} as Record<string, string>,
    status(code: number) {
      res.statusCode = code;
      return res;
    },
    json(payload: unknown) {
      res.body = payload;
      return res;
    },
    setHeader(key: string, value: string) {
      res.headers[key] = value;
    },
  };
  return res as unknown as VercelResponse & typeof res;
}

const ORIGINAL_ENV = { ...process.env };

beforeEach(() => {
  process.env = { ...ORIGINAL_ENV };
  createMock.mockReset();
});

afterEach(() => {
  process.env = ORIGINAL_ENV;
});

describe('POST /api/generate', () => {
  it('rejects non-POST methods with 405', async () => {
    const req = { method: 'GET' } as VercelRequest;
    const res = createRes();

    await handler(req, res);

    expect(res.statusCode).toBe(405);
  });

  it('rejects an invalid body with 400', async () => {
    process.env.MOCK_AI = 'true';
    const req = { method: 'POST', body: {} } as VercelRequest;
    const res = createRes();

    await handler(req, res);

    expect(res.statusCode).toBe(400);
    expect(createMock).not.toHaveBeenCalled();
  });

  it('rejects a photoBase64 payload larger than the 6MB limit with 400', async () => {
    process.env.MOCK_AI = 'true';
    const req = {
      method: 'POST',
      body: { photoBase64: 'a'.repeat(6 * 1024 * 1024 + 1) },
    } as VercelRequest;
    const res = createRes();

    await handler(req, res);

    expect(res.statusCode).toBe(400);
    expect(createMock).not.toHaveBeenCalled();
  });

  it('returns the mock listing without calling the Anthropic API', async () => {
    process.env.MOCK_AI = 'true';
    const req = { method: 'POST', body: { photoBase64: 'fake-data' } } as VercelRequest;
    const res = createRes();

    await handler(req, res);

    expect(res.statusCode).toBe(200);
    expect((res.body as { listing: { title: string } }).listing.title).toContain('MOCK');
    expect(createMock).not.toHaveBeenCalled();
  });

  it('returns 502 when the Anthropic call fails', async () => {
    process.env.MOCK_AI = 'false';
    process.env.ANTHROPIC_API_KEY = 'test-key';
    createMock.mockRejectedValue(new Error('boom'));

    const req = { method: 'POST', body: { photoBase64: 'fake-data' } } as VercelRequest;
    const res = createRes();

    await handler(req, res);

    expect(res.statusCode).toBe(502);
  });

  it('parses a tool_use response into a listing', async () => {
    process.env.MOCK_AI = 'false';
    process.env.ANTHROPIC_API_KEY = 'test-key';
    createMock.mockResolvedValue({
      content: [
        {
          type: 'tool_use',
          input: {
            title: '실제 제목',
            description: '실제 설명입니다.',
            category: '가전',
            price: 10000,
            priceRangeMin: 9000,
            priceRangeMax: 11000,
          },
        },
      ],
    });

    const req = { method: 'POST', body: { photoBase64: 'fake-data' } } as VercelRequest;
    const res = createRes();

    await handler(req, res);

    expect(res.statusCode).toBe(200);
    expect((res.body as { listing: { title: string } }).listing.title).toBe('실제 제목');
  });
});
