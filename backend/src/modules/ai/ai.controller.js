import { asyncHandler } from '../../utils/async-handler.js';
import { sendSuccess, sendCreated } from '../../utils/api-response.js';
import { toAnalysisDto, toChatDetailDto, toChatSummaryDto, toMessageDto, toRecommendationDto } from './ai.dto.js';
import {
  analyzeOutfit,
  deleteAllChats,
  deleteChat,
  getChatDetail,
  listChatHistory,
  recommendOutfit,
  sendChatMessage,
} from './ai.service.js';

export const chat = asyncHandler(async (req, res) => {
  const { chat: updatedChat, userMessage, aiMessage } = await sendChatMessage(req.user.id, req.body);

  return sendSuccess(res, 200, 'Message sent successfully', {
    chat: toChatSummaryDto(updatedChat),
    userMessage: toMessageDto(userMessage),
    aiMessage: toMessageDto(aiMessage),
  });
});

export const analyze = asyncHandler(async (req, res) => {
  const recommendation = await analyzeOutfit(req.user.id, { file: req.file, notes: req.body.notes });

  return sendCreated(res, 'Outfit analyzed successfully', {
    analysis: toAnalysisDto(recommendation),
  });
});

export const recommend = asyncHandler(async (req, res) => {
  const recommendation = await recommendOutfit(req.user.id, req.body);

  return sendCreated(res, 'Recommendation generated successfully', {
    recommendation: toRecommendationDto(recommendation),
  });
});

export const getHistory = asyncHandler(async (req, res) => {
  const chats = await listChatHistory(req.user.id);

  return sendSuccess(res, 200, 'Chat history retrieved successfully', {
    chats: chats.map(toChatSummaryDto),
  });
});

export const getHistoryDetail = asyncHandler(async (req, res) => {
  const chatDetail = await getChatDetail(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Conversation retrieved successfully', {
    chat: toChatDetailDto(chatDetail),
  });
});

export const deleteHistoryItem = asyncHandler(async (req, res) => {
  await deleteChat(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Conversation deleted successfully', {});
});

export const deleteAllHistory = asyncHandler(async (req, res) => {
  await deleteAllChats(req.user.id);

  return sendSuccess(res, 200, 'Chat history cleared successfully', {});
});
