import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

/// Real backend access for the wardrobe feature.
///
/// Covers reading the user's own wardrobe items (`GET /wardrobe`) and
/// adding a new item with a captured photo (`POST /wardrobe`). Saved
/// outfits/marketplace/favorite-toggle continue to use the existing local
/// mock datasource; wiring those to the backend is a separate, unrelated
/// piece of work.
abstract class WardrobeRemoteDataSource {
  Future<List<dynamic>> getWardrobeItems();

  /// Creates a wardrobe item on the backend with a photo. Returns the
  /// created item's JSON.
  Future<Map<String, dynamic>> addWardrobeItem({
    required String name,
    required String category,
    String? subCategory,
    required File image,
  });
}

class WardrobeRemoteDataSourceImpl implements WardrobeRemoteDataSource {
  final DioClient dioClient;

  WardrobeRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<dynamic>> getWardrobeItems() async {
    try {
      final response = await dioClient.get(ApiConstants.wardrobe);
      if (response.data is Map<String, dynamic>) {
        final envelope = response.data as Map<String, dynamic>;
        final data = envelope['data'];
        if (data is Map<String, dynamic> && data['items'] is List) {
          return data['items'] as List<dynamic>;
        }
      }
      throw const ServerException('Invalid wardrobe response from server');
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> addWardrobeItem({
    required String name,
    required String category,
    String? subCategory,
    required File image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'category': category,
        'subCategory': ?subCategory,
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.uri.pathSegments.last,
        ),
      });

      final response = await dioClient.post(ApiConstants.wardrobe, data: formData);
      if (response.data is Map<String, dynamic>) {
        final envelope = response.data as Map<String, dynamic>;
        final data = envelope['data'];
        if (data is Map<String, dynamic> && data['item'] is Map) {
          return Map<String, dynamic>.from(data['item'] as Map);
        }
      }
      throw const ServerException('Invalid add-item response from server');
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
