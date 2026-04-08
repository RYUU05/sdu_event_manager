import 'package:dartz/dartz.dart';
import 'package:event_manager/features/home/domain/repositories/home_repository.dart';

class RegisterForEvent {
  final HomeRepository repository;

  RegisterForEvent(this.repository);

  Future<Either<String, void>> call(String eventId) async {
    return await repository.registerForEvent(eventId);
  }
}
