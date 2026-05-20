import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_service.dart';
import '../../domain/entities/food.dart';

class FoodRemoteDataSource {
  final ApiService _api;
  FoodRemoteDataSource(this._api);

  String get _apiKey {
    try {
      if (!dotenv.isInitialized) return '';
      return dotenv.env['GROK_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<Uint8List> _resizeImageIfNeeded(Uint8List bytes, {int maxDimension = 1024}) async {
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: null,
        targetHeight: null,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      if (image.width > maxDimension || image.height > maxDimension) {
        final double scale = maxDimension / (image.width > image.height ? image.width : image.height);
        final int targetWidth = (image.width * scale).toInt();
        final int targetHeight = (image.height * scale).toInt();

        final ui.Codec resizedCodec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        );
        final ui.FrameInfo resizedFrame = await resizedCodec.getNextFrame();
        final ui.Image resizedImage = resizedFrame.image;

        final ByteData? byteData = await resizedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData != null) {
          return byteData.buffer.asUint8List();
        }
      }
    } catch (e) {
      debugPrint('Error resizing image: $e');
    }
    return bytes;
  }

  Future<Either<Failure, Food>> detectFoodAndCalories(XFile imageFile) async {
    try {
      // Attempt on-demand load if not yet initialized
      if (_apiKey.isEmpty) {
        try {
          await dotenv.load(fileName: 'env');
        } catch (_) {}
      }

      if (_apiKey.isEmpty) {
        return left(const NetworkFailure('Missing GROK_API_KEY. Please verify your environment configuration.'));
      }

      final rawBytes = await imageFile.readAsBytes();
      final compressedBytes = await _resizeImageIfNeeded(rawBytes);
      final base64Image = base64Encode(compressedBytes);
      
      final mimeType = (imageFile.name.toLowerCase().endsWith('.png') || rawBytes.length != compressedBytes.length)
          ? 'image/png'
          : 'image/jpeg';

      final targetUrl = 'https://api.groq.com/openai/v1/chat/completions';
      final uri = Uri.parse(targetUrl);

      final response = await _api.postJson(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: {
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
                },
                {
                  'type': 'text',
                  'text':
                      'Analyze this image and identify the food. '
                      'Estimate its calories, protein, carbs, and fat. '
                      'Return JSON only, no markdown, no explanation, in this exact format: '
                      '{"name": "food name", "calories": 100, "protein": 10, "carbs": 20, "fat": 5}',
                },
              ],
            },
          ],
          'max_tokens': 200,
        },
      );

      return response.flatMap((data) {
        try {
          final output = data['choices']?[0]?['message']?['content'];
          if (output is! String) {
            return left(NetworkFailure('Invalid API response', cause: data));
          }

          final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(output);
          if (match == null) {
            return left(NetworkFailure('No JSON found in response', cause: output));
          }

          final foodData = jsonDecode(match.group(0)!);
          if (foodData is! Map) {
            return left(NetworkFailure('Invalid JSON in response', cause: output));
          }

          double parseDouble(dynamic value) {
            if (value == null) return 0.0;
            if (value is num) return value.toDouble();
            if (value is String) {
              return double.tryParse(value) ?? 0.0;
            }
            return 0.0;
          }

          return right(
            Food(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: (foodData['name'] ?? 'Unknown Food').toString(),
              calories: parseDouble(foodData['calories']),
              protein: parseDouble(foodData['protein']),
              carbs: parseDouble(foodData['carbs']),
              fat: parseDouble(foodData['fat']),
              quantity: 100.0,
              timestamp: DateTime.now(),
            ),
          );
        } catch (e) {
          return left(NetworkFailure('Failed to parse API response: $e', cause: e));
        }
      });
    } catch (e) {
      return left(NetworkFailure('Failed to detect food: $e', cause: e));
    }
  }
}


