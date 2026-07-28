import { sendSuccess } from '../utils/api-response.js';

export const getHealth = (req, res) =>
  sendSuccess(res, 200, 'StyleSense AI API is healthy', {
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
