import '../entities/level.dart';
import '../repositories/game_repository.dart';

class GetLevelsUseCase {
  GetLevelsUseCase(this._repository);

  final GameRepository _repository;

  Future<List<Level>> call() {
    return _repository.fetchLevels();
  }
}
