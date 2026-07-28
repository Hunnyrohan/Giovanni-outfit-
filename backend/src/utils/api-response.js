export class ApiResponse {
  constructor(statusCode, data, message = 'Success') {
    this.statusCode = statusCode;
    this.success = statusCode < 400;
    this.message = message;
    this.data = data;
  }
}

export const sendSuccess = (res, statusCode = 200, message = 'Success', data = {}) => {
  const response = new ApiResponse(statusCode, data, message);

  return res.status(statusCode).json({
    success: response.success,
    message: response.message,
    data: response.data,
  });
};

export const sendCreated = (res, message = 'Resource created successfully', data = {}) =>
  sendSuccess(res, 201, message, data);
