import fs from 'fs/promises';
import { ApiError } from '../../utils/api-error.js';
import { aiRepository } from './ai.repository.js';
import * as gemini from '../../services/gemini.service.js';

const OCCASION_KEYWORDS = {
  CASUAL: ['casual', 'everyday', 'weekend'],
  FORMAL: ['formal', 'gala', 'black tie'],
  BUSINESS: ['business', 'office', 'work', 'meeting', 'interview'],
  PARTY: ['party', 'birthday', 'celebration'],
  SPORTS: ['sports', 'gym', 'workout', 'run'],
  TRAVEL: ['travel', 'trip', 'vacation', 'flight'],
  DATE: ['date night', 'date'],
  FESTIVAL: ['festival', 'concert'],
};

const mapOccasionToEnum = (occasion) => {
  if (!occasion) {
    return null;
  }

  const lower = occasion.toLowerCase();

  for (const [enumValue, keywords] of Object.entries(OCCASION_KEYWORDS)) {
    if (keywords.some((keyword) => lower.includes(keyword))) {
      return enumValue;
    }
  }

  return 'OTHER';
};

const deriveTitle = (message) => {
  const trimmed = message.trim();
  return trimmed.length > 60 ? `${trimmed.slice(0, 60)}...` : trimmed;
};

const assertOwnedChat = async (userId, chatId) => {
  const chat = await aiRepository.findChatForUser(chatId, userId);

  if (!chat) {
    throw new ApiError(404, 'Conversation not found');
  }

  return chat;
};

const buildGeminiHistory = (messages) =>
  messages
    .filter((message) => message.sender === 'USER' || message.sender === 'AI')
    .map((message) => ({
      role: message.sender === 'USER' ? 'user' : 'model',
      text: message.content,
    }));

export const sendChatMessage = async (userId, { chatId, message }) => {
  let chat;
  let priorMessages = [];

  if (chatId) {
    const existing = await aiRepository.findChatWithMessages(chatId, userId);

    if (!existing) {
      throw new ApiError(404, 'Conversation not found');
    }

    chat = existing;
    priorMessages = existing.messages;
  } else {
    chat = await aiRepository.createChat(userId, deriveTitle(message));
  }

  const userMessage = await aiRepository.addMessage(chat.id, {
    sender: 'USER',
    content: message,
  });

  const history = buildGeminiHistory(priorMessages);
  const replyText = await gemini.chatCompletion({ history, message });

  const aiMessage = await aiRepository.addMessage(chat.id, {
    sender: 'AI',
    content: replyText,
  });

  const updatedChat = await aiRepository.updateChat(chat.id, {
    summary: replyText.length > 140 ? `${replyText.slice(0, 140)}...` : replyText,
  });

  return { chat: updatedChat, userMessage, aiMessage };
};

export const analyzeOutfit = async (userId, { file, notes }) => {
  if (!file) {
    throw new ApiError(400, 'Please upload an outfit image to analyze');
  }

  const imageUrl = `/uploads/outfits/${file.filename}`;
  const imageBuffer = await fs.readFile(file.path);
  const analysis = await gemini.analyzeOutfitImage({
    imageBuffer,
    mimeType: file.mimetype,
    notes,
  });

  const recommendation = await aiRepository.createRecommendation({
    userId,
    title: analysis.summary?.slice(0, 80) || 'Outfit analysis',
    type: 'OUTFIT_ANALYSIS',
    score: analysis.score,
    payload: {
      summary: analysis.summary,
      colorAnalysis: analysis.colorAnalysis,
      strengths: analysis.strengths,
      improvements: analysis.improvements,
      imageUrl,
    },
  });

  return recommendation;
};

export const recommendOutfit = async (userId, { occasion, notes }) => {
  const wardrobeItems = await aiRepository.findWardrobeItemsForUser(userId);

  const recommendation = await gemini.generateRecommendation({
    occasion,
    notes,
    wardrobeItems,
  });

  return aiRepository.createRecommendation({
    userId,
    title: recommendation.title?.slice(0, 80) || 'Outfit recommendation',
    type: 'OCCASION_RECOMMENDATION',
    occasion: mapOccasionToEnum(occasion),
    payload: {
      reasoning: recommendation.reasoning,
      suggestions: recommendation.suggestions,
      accessories: recommendation.accessories,
    },
  });
};

export const listChatHistory = async (userId) => aiRepository.listChatsForUser(userId);

export const getChatDetail = async (userId, chatId) => {
  const chat = await aiRepository.findChatWithMessages(chatId, userId);

  if (!chat) {
    throw new ApiError(404, 'Conversation not found');
  }

  return chat;
};

export const deleteChat = async (userId, chatId) => {
  await assertOwnedChat(userId, chatId);
  await aiRepository.deleteChat(chatId);
  return {};
};

export const deleteAllChats = async (userId) => {
  await aiRepository.deleteAllChatsForUser(userId);
  return {};
};
