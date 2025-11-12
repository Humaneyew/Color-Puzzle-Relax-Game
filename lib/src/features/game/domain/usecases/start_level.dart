import '../entities/game_session.dart';
import '../repositories/game_repository.dart';

class StartLevelUseCase {
  StartLevelUseCase(this._repository);

  final GameRepository _repository;

  Future<GameSession> call(String levelId) {
    return _repository.startSession(levelId);
  }
}
