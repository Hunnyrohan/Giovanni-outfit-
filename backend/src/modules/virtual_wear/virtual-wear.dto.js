// Never expose the AI Service's raw host/path (e.g. "http://localhost:8000/outputs/x.png")
// or a local filesystem path - always route through our own proxy endpoint.
// Path is relative to the API root (matching every other ApiConstants entry
// on the Flutter side, e.g. '/ai/chat') - the client's own baseUrl already
// includes the /api prefix, so it must NOT be baked in here too.
export const toTryOnDto = (tryOn) => ({
  id: tryOn.id,
  wardrobeItemId: tryOn.wardrobeItemId,
  status: tryOn.status,
  resultImageUrl: tryOn.resultImageUrl ? `/virtual-tryon/${tryOn.id}/image` : null,
  processingTime: tryOn.processingTime,
  errorMessage: tryOn.errorMessage,
  createdAt: tryOn.createdAt,
  updatedAt: tryOn.updatedAt,
});
