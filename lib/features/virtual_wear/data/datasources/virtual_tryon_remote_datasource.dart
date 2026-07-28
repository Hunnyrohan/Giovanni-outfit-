import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

abstract class VirtualTryOnRemoteDataSource {
  Future<Map<String, dynamic>> createTryOn({
    required String wardrobeItemId,
    required File personImage,
  });
  Future<Map<String, dynamic>> getStatus(String jobId);
  Future<List<dynamic>> getHistory();
  Future<void> deleteTryOn(String jobId);
  Future<void> saveToOutfits(String jobId, {String? title});
}

class VirtualTryOnRemoteDataSourceImpl implements VirtualTryOnRemoteDataSource {
  final DioClient dioClient;

  VirtualTryOnRemoteDataSourceImpl(this.dioClient);

  Map<String, dynamic> _unwrapData(Response response) {
    if (response.data is Map<String, dynamic>) {
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    throw const ServerException('Invalid response from server');
  }

  @override
  Future<Map<String, dynamic>> createTryOn({
    required String wardrobeItemId,
    required File personImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'wardrobeItemId': wardrobeItemId,
        'personImage': await MultipartFile.fromFile(
          personImage.path,
          filename: personImage.uri.pathSegments.last,
        ),
      });

      // The AI Service lazy-loads its model singleton on the very first
      // request after a (re)start, which alone can take ~25-30s before it
      // even accepts the job - well past the app's global 15s receiveTimeout
      // used for ordinary CRUD calls. Give this one call more headroom so a
      // cold start doesn't surface as a client-side timeout even though the
      // backend/AI Service go on to complete the job successfully.
      final response = await dioClient.post(
        ApiConstants.virtualTryOn,
        data: formData,
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );
      final data = _unwrapData(response);
      return data['tryOn'] as Map<String, dynamic>;
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getStatus(String jobId) async {
    try {
      final response = await dioClient.get(ApiConstants.virtualTryOnItem(jobId));
      final data = _unwrapData(response);
      return data['tryOn'] as Map<String, dynamic>;
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getHistory() async {
    try {
      final response = await dioClient.get(ApiConstants.virtualTryOnHistory);
      final data = _unwrapData(response);
      return data['tryOns'] as List<dynamic>? ?? [];
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTryOn(String jobId) async {
    try {
      await dioClient.delete(ApiConstants.virtualTryOnItem(jobId));
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> saveToOutfits(String jobId, {String? title}) async {
    try {
      await dioClient.post(
        ApiConstants.virtualTryOnSave(jobId),
        data: {if (title != null) 'title': title},
      );
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
