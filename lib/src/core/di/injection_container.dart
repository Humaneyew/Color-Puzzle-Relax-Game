import 'package:get_it/get_it.dart';

import '../logic/board_generator.dart';
import '../../features/game/data/datasources/local_level_data_source.dart';
import '../../features/game/data/repositories/game_repository_impl.dart';
import '../../features/game/domain/repositories/game_repository.dart';
import '../../features/game/domain/usecases/get_levels.dart';
import '../../features/game/domain/usecases/save_progress.dart';
import '../../features/game/domain/usecases/start_level.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies() async {
  _registerDataSources();
  _registerLogic();
  _registerRepositories();
  _registerUseCases();
}

void _registerDataSources() {
  serviceLocator.registerLazySingleton<LevelDataSource>(
    LocalLevelDataSource.new,
  );
}

void _registerLogic() {
  serviceLocator.registerLazySingleton<BoardGenerator>(
    BoardGenerator.new,
  );
}

void _registerRepositories() {
  serviceLocator.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(serviceLocator(), serviceLocator()),
  );
}

void _registerUseCases() {
  serviceLocator.registerLazySingleton<GetLevelsUseCase>(
    () => GetLevelsUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<StartLevelUseCase>(
    () => StartLevelUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<SaveProgressUseCase>(
    () => SaveProgressUseCase(serviceLocator()),
  );
}
