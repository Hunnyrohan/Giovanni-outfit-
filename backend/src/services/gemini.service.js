import { GoogleGenAI, Type } from '@google/genai';
import { env } from '../config/env.js';
import { ApiError } from '../utils/api-error.js';

const STYLIST_PERSONA = `You are StyleSense AI, a professional fashion stylist and personal styling consultant.
You give expert, warm, and concise advice on outfits, color matching, accessories, occasion-appropriate
styling, and general wardrobe guidance. You NEVER answer questions unrelated to fashion, clothing, styling,
or personal presentation - if asked something off-topic, politely decline and steer the conversation back to
fashion and style. Keep replies conversational and free of markdown formatting (no asterisks, no headers,
no bullet lists with markdown syntax) since responses are rendered as plain chat text.`;

let client = null;

const getClient = () => {
  if (!env.geminiApiKey) {
    throw new ApiError(500, 'AI Stylist is not configured', {
      GEMINI_API_KEY: 'Set GEMINI_API_KEY in backend/.env',
    });
  }

  if (!client) {
    client = new GoogleGenAI({ apiKey: env.geminiApiKey });
  }

  return client;
};

const mapGeminiError = (error) => {
  const status = error?.status ?? error?.response?.status;

  if (status === 429) {
    return new ApiError(429, 'AI Stylist is receiving too many requests right now. Please try again shortly.');
  }

  if (status === 400) {
    return new ApiError(400, 'AI Stylist could not process that request.', {
      detail: error?.message,
    });
  }

  if (status === 403 || status === 401) {
    return new ApiError(500, 'AI Stylist is not configured correctly.', {
      GEMINI_API_KEY: 'Check that GEMINI_API_KEY in backend/.env is valid',
    });
  }

  if (error?.name === 'AbortError' || status === 504 || status === 408) {
    return new ApiError(504, 'AI Stylist took too long to respond. Please try again.');
  }

  return new ApiError(502, 'AI Stylist is temporarily unavailable. Please try again.');
};

/**
 * @param {{ history: {role: 'user'|'model', text: string}[], message: string }} params
 * @returns {Promise<string>}
 */
export const chatCompletion = async ({ history, message }) => {
  try {
    const ai = getClient();
    const contents = [
      ...history.map((turn) => ({ role: turn.role, parts: [{ text: turn.text }] })),
      { role: 'user', parts: [{ text: message }] },
    ];

    const response = await ai.models.generateContent({
      model: env.geminiModel,
      contents,
      config: {
        systemInstruction: STYLIST_PERSONA,
        temperature: 0.8,
      },
    });

    const text = response.text?.trim();

    if (!text) {
      throw new ApiError(502, 'AI Stylist returned an empty response.');
    }

    return text;
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    throw mapGeminiError(error);
  }
};

const ANALYSIS_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    score: { type: Type.INTEGER, description: 'Overall outfit score from 0 to 100' },
    summary: { type: Type.STRING, description: 'One or two sentence overall verdict' },
    colorAnalysis: { type: Type.STRING, description: 'Assessment of the color palette and combination' },
    strengths: { type: Type.ARRAY, items: { type: Type.STRING } },
    improvements: { type: Type.ARRAY, items: { type: Type.STRING } },
  },
  required: ['score', 'summary', 'colorAnalysis', 'strengths', 'improvements'],
};

/**
 * @param {{ imageBuffer: Buffer, mimeType: string, notes?: string }} params
 */
export const analyzeOutfitImage = async ({ imageBuffer, mimeType, notes }) => {
  try {
    const ai = getClient();
    const prompt = notes
      ? `Analyze this outfit photo. Additional context from the user: "${notes}"`
      : 'Analyze this outfit photo.';

    const response = await ai.models.generateContent({
      model: env.geminiModel,
      contents: [
        {
          role: 'user',
          parts: [
            { text: prompt },
            { inlineData: { mimeType, data: imageBuffer.toString('base64') } },
          ],
        },
      ],
      config: {
        systemInstruction: STYLIST_PERSONA,
        temperature: 0.6,
        responseMimeType: 'application/json',
        responseSchema: ANALYSIS_SCHEMA,
      },
    });

    const text = response.text?.trim();

    if (!text) {
      throw new ApiError(502, 'AI Stylist returned an empty analysis.');
    }

    try {
      return JSON.parse(text);
    } catch {
      throw new ApiError(502, 'AI Stylist returned an unreadable analysis.');
    }
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    throw mapGeminiError(error);
  }
};

const RECOMMENDATION_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    title: { type: Type.STRING, description: 'Short title for this recommendation' },
    reasoning: { type: Type.STRING, description: 'Why these suggestions fit the occasion' },
    suggestions: { type: Type.ARRAY, items: { type: Type.STRING }, description: 'Outfit/style suggestions' },
    accessories: { type: Type.ARRAY, items: { type: Type.STRING }, description: 'Accessory suggestions' },
  },
  required: ['title', 'reasoning', 'suggestions', 'accessories'],
};

/**
 * @param {{ occasion?: string, notes?: string, wardrobeItems: {name: string, category: string, primaryColor?: string}[] }} params
 */
export const generateRecommendation = async ({ occasion, notes, wardrobeItems }) => {
  try {
    const ai = getClient();
    const wardrobeContext = wardrobeItems.length
      ? `The user's available wardrobe items: ${wardrobeItems
          .map((item) => `${item.name} (${item.category}${item.primaryColor ? `, ${item.primaryColor}` : ''})`)
          .join('; ')}.`
      : 'The user has no wardrobe items on file yet, so suggest general pieces.';

    const prompt = [
      occasion ? `Occasion: ${occasion}.` : 'No specific occasion given - suggest versatile everyday styling.',
      notes ? `User notes: "${notes}".` : null,
      wardrobeContext,
      'Recommend a complete outfit styling plan.',
    ]
      .filter(Boolean)
      .join(' ');

    const response = await ai.models.generateContent({
      model: env.geminiModel,
      contents: [{ role: 'user', parts: [{ text: prompt }] }],
      config: {
        systemInstruction: STYLIST_PERSONA,
        temperature: 0.8,
        responseMimeType: 'application/json',
        responseSchema: RECOMMENDATION_SCHEMA,
      },
    });

    const text = response.text?.trim();

    if (!text) {
      throw new ApiError(502, 'AI Stylist returned an empty recommendation.');
    }

    try {
      return JSON.parse(text);
    } catch {
      throw new ApiError(502, 'AI Stylist returned an unreadable recommendation.');
    }
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    throw mapGeminiError(error);
  }
};
