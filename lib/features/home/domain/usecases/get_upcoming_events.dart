import 'package:dartz/dartz.dart';
import 'package:event_manager/features/home/domain/entities/event.dart';
import 'package:event_manager/features/home/domain/repositories/home_repository.dart';

class GetUpcomingEvents {
  final HomeRepository repository;

  GetUpcomingEvents(this.repository);

  Future<Either<String, List<Event>>> call() async {
    return await repository.getUpcomingEvents();
  }
}
