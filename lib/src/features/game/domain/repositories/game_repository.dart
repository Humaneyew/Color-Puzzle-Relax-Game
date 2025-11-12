import '../entities/game_session.dart';
import '../entities/level.dart';

abstract class GameRepository {
  Future<List<Level>> fetchLevels();
  Future<GameSession> startSession(String levelId);
  Future<void> saveProgress(GameSession session);
}
