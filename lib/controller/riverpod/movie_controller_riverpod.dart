import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_app/api/api_movies_services.dart';

// Định nghĩa một FutureProvider.family để có thể truyền tham số slug
final movieDetailProvider = FutureProvider.family((ref, slug) {
  try {
    return ApiServices.getMovieDetail(slug.toString());
  } catch (e) {
    throw Exception('Failed to load movie details: $e');
  }
});
