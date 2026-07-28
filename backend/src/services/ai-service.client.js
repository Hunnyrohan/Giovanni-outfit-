import fs from 'fs/promises';
import path from 'path';
import { env } from '../config/env.js';
import { ApiError } from '../utils/api-error.js';

const withTimeout = async (requestFn) => {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), env.aiServiceTimeoutMs);

  try {
    return await requestFn(controller.signal);
  } finally {
    clearTimeout(timeout);
  }
};

const MIME_TYPES_BY_EXTENSION = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
};

const mimeTypeFor = (filePath) => MIME_TYPES_BY_EXTENSION[path.extname(filePath).toLowerCase()] || 'image/jpeg';

const mapAiServiceError = (error) => {
  if (error instanceof ApiError) {
    return error;
  }

  if (error?.name === 'AbortError') {
    return new ApiError(504, 'AI Service took too long to respond. Please try again.');
  }

  return new ApiError(502, 'AI Service is currently unavailable. Please try again later.', {
    detail: error?.message,
  });
};

/**
 * Submits a person image + garment image to the FastAPI AI Service and
 * returns its job response ({jobId, status, imageUrl, processingTime, ...}).
 */
export const createTryOnJob = async ({ personImagePath, garmentImagePath, garmentType }) => {
  try {
    const [personBuffer, garmentBuffer] = await Promise.all([
      fs.readFile(personImagePath),
      fs.readFile(garmentImagePath),
    ]);

    const form = new FormData();
    form.append(
      'person_image',
      new Blob([personBuffer], { type: mimeTypeFor(personImagePath) }),
      path.basename(personImagePath),
    );
    form.append(
      'garment_image',
      new Blob([garmentBuffer], { type: mimeTypeFor(garmentImagePath) }),
      path.basename(garmentImagePath),
    );
    form.append('garment_type', garmentType);

    const response = await withTimeout((signal) =>
      fetch(`${env.aiServiceUrl}/virtual-tryon`, { method: 'POST', body: form, signal }),
    );

    if (!response.ok) {
      const body = await response.text().catch(() => '');
      throw new ApiError(502, `AI Service rejected the request (${response.status})`, { detail: body });
    }

    return await response.json();
  } catch (error) {
    throw mapAiServiceError(error);
  }
};

export const getTryOnJobStatus = async (providerJobId) => {
  try {
    const response = await withTimeout((signal) =>
      fetch(`${env.aiServiceUrl}/virtual-tryon/status/${providerJobId}`, { signal }),
    );

    if (response.status === 404) {
      throw new ApiError(404, 'Try-on job was not found on the AI Service');
    }

    if (!response.ok) {
      throw new ApiError(502, `AI Service returned an error (${response.status})`);
    }

    return await response.json();
  } catch (error) {
    throw mapAiServiceError(error);
  }
};

/** Best-effort: an unreachable AI Service should never block deleting our own record. */
export const deleteTryOnJob = async (providerJobId) => {
  try {
    const response = await withTimeout((signal) =>
      fetch(`${env.aiServiceUrl}/virtual-tryon/${providerJobId}`, { method: 'DELETE', signal }),
    );

    if (!response.ok && response.status !== 404) {
      throw new ApiError(502, `AI Service returned an error (${response.status})`);
    }
  } catch {
    // Swallowed deliberately - see docstring.
  }
};

/**
 * Streams the generated result image from the AI Service's static file host.
 * Returns the raw fetch Response so the caller can pipe headers/body through
 * without writing a duplicate copy to this server's own disk.
 */
export const fetchResultImage = async (imagePath) => {
  try {
    const response = await withTimeout((signal) => fetch(`${env.aiServiceUrl}${imagePath}`, { signal }));

    if (!response.ok) {
      throw new ApiError(502, 'Could not fetch the generated image from the AI Service');
    }

    return response;
  } catch (error) {
    throw mapAiServiceError(error);
  }
};
