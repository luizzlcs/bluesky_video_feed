import 'package:get_it/get_it.dart';

import '../../features/feed/data/datasources/bluesky_datasource.dart';
import '../../features/feed/data/repositories/feed_repository.dart';
import '../../features/feed/feed_controller.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Datasources
  getIt.registerLazySingleton<BlueskyDatasource>(() => BlueskyDatasource());
  
  // Repositories
  getIt.registerLazySingleton<FeedRepository>(
      () => FeedRepository(datasource: getIt<BlueskyDatasource>()));
  
  // Controllers
  getIt.registerSingleton<FeedController>(
      FeedController(repository: getIt<FeedRepository>()));
}