import fs from 'fs';
import multer from 'multer';
import path from 'path';
import { env } from '../config/env.js';
import { ApiError } from '../utils/api-error.js';

const uploadRoot = path.join(process.cwd(), 'uploads');
const allowedFolders = new Set(['profile', 'wardrobe', 'outfits', 'virtual', 'collections']);

const ensureDirectory = (directory) => {
  if (!fs.existsSync(directory)) {
    fs.mkdirSync(directory, { recursive: true });
  }
};

const sanitizeFilename = (filename) =>
  filename
    .toLowerCase()
    .replace(/[^a-z0-9.-]/g, '-')
    .replace(/-+/g, '-');

ensureDirectory(uploadRoot);

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const folder = req.uploadFolder || 'wardrobe';

    if (!allowedFolders.has(folder)) {
      cb(new ApiError(400, 'Invalid upload folder'));
      return;
    }

    const destination = path.join(uploadRoot, folder);
    ensureDirectory(destination);
    cb(null, destination);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const safeName = sanitizeFilename(path.parse(file.originalname).name);
    cb(null, `${file.fieldname}-${safeName}-${uniqueSuffix}${path.extname(file.originalname)}`);
  },
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
    return;
  }

  cb(new ApiError(400, 'Only image files are allowed'), false);
};

export const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: env.maxUploadSizeMb * 1024 * 1024,
  },
});

export const setUploadFolder = (folder) => (req, res, next) => {
  req.uploadFolder = folder;
  next();
};
