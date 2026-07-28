export const parseListInput = (value) => {
  if (Array.isArray(value)) {
    return value;
  }

  if (typeof value !== 'string' || value.trim() === '') {
    return [];
  }

  try {
    const parsed = JSON.parse(value);
    if (Array.isArray(parsed)) {
      return parsed;
    }
  } catch (error) {
    // Not JSON — fall back to comma-separated parsing below.
  }

  return value
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
};
