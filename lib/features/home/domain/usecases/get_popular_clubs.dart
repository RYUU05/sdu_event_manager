import 'package:dartz/dartz.dart';
import 'package:event_manager/features/home/domain/entities/club.dart';
import 'package:event_manager/features/home/domain/repositories/home_repository.dart';

class GetPopularClubs {
  final HomeRepository repository;

  GetPopularClubs(this.repository);

  Future<Either<String, List<Club>>> call() async {
    return await repository.getPopularClubs();
  }
}
