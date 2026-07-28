import { ApiError } from '../utils/api-error.js';

export const validate = (schema) => async (req, res, next) => {
  try {
    const parsedData = await schema.parseAsync({
      body: req.body,
      query: req.query,
      params: req.params,
    });

    if (parsedData.body !== undefined) {
      req.body = parsedData.body;
    }

    if (parsedData.params !== undefined) {
      req.params = parsedData.params;
    }

    if (parsedData.query !== undefined) {
      req.validatedQuery = parsedData.query;
    }

    return next();
  } catch (error) {
    if (!error.issues) {
      return next(error);
    }

    const formattedErrors = (error.issues || []).reduce((acc, issue) => {
      const path = issue.path.join('.') || 'request';
      acc[path] = issue.message;
      return acc;
    }, {});

    return next(new ApiError(400, 'Validation failed', formattedErrors));
  }
};
