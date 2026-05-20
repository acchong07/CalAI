import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failure.dart';
import '../entities/food.dart';
import '../repositories/food_repository.dart';

class DetectFoodFromImage {
  final FoodRepository _repo;
  DetectFoodFromImage(this._repo);

  Future<Either<Failure, Food>> call(XFile image) {
    return _repo.detectFoodFromImage(image);
  }
}

