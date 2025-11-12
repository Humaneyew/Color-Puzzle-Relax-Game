import '../entities/game_session.dart';
import '../repositories/game_repository.dart';

class SaveProgressUseCase {
  SaveProgressUseCase(this._repository);

  final GameRepository _repository;

  Future<void> call(GameSession session) {
    return _repository.saveProgress(session);
  }
}
