export const toMessageDto = (message) => ({
  id: message.id,
  chatId: message.chatId,
  sender: message.sender,
  content: message.content,
  metadata: message.metadata,
  createdAt: message.createdAt,
  updatedAt: message.updatedAt,
});

export const toChatSummaryDto = (chat) => ({
  id: chat.id,
  title: chat.title,
  summary: chat.summary,
  createdAt: chat.createdAt,
  updatedAt: chat.updatedAt,
});

export const toChatDetailDto = (chat) => ({
  ...toChatSummaryDto(chat),
  messages: chat.messages.map(toMessageDto),
});

export const toAnalysisDto = (recommendation) => ({
  id: recommendation.id,
  title: recommendation.title,
  score: recommendation.score,
  ...recommendation.payload,
  createdAt: recommendation.createdAt,
});

export const toRecommendationDto = (recommendation) => ({
  id: recommendation.id,
  title: recommendation.title,
  occasion: recommendation.occasion,
  ...recommendation.payload,
  createdAt: recommendation.createdAt,
});
