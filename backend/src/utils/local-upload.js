import fs from 'fs/promises';
import path from 'path';

const uploadRoot = path.join(process.cwd(), 'uploads');

export const deleteUploadedFile = async (fileUrl) => {
  if (!fileUrl) {
    return;
  }

  const uploadsMarker = '/uploads/';
  const markerIndex = fileUrl.indexOf(uploadsMarker);

  if (markerIndex === -1) {
    return;
  }

  const relativePath = fileUrl.slice(markerIndex + uploadsMarker.length);
  const absolutePath = path.join(uploadRoot, relativePath);

  try {
    await fs.unlink(absolutePath);
  } catch (error) {
    if (error.code !== 'ENOENT') {
      throw error;
    }
  }
};
