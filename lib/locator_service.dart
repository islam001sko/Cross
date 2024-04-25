import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rick_and_morty/core/platform/network_info.dart';
import 'package:rick_and_morty/features/data/datasources/person_local_datasource.dart';
import 'package:rick_and_morty/features/data/datasources/person_remote_datasource.dart';
import 'package:rick_and_morty/features/data/repositories/person_repository_implement.dart';
import 'package:rick_and_morty/features/domain/respositories/person_repository.dart';
import 'package:rick_and_morty/features/domain/usecases/get_all_persons.dart';
import 'package:rick_and_morty/features/domain/usecases/search_person.dart';
import 'package:rick_and_morty/features/presentation/bloc/person_list_cubit/person_list_cubit.dart';
import 'package:rick_and_morty/features/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  //Bloc, Cubit
  sl.registerFactory(() => PersonListCubit(getAllPersons: sl()));
  sl.registerFactory(() => PersonSearchBloc(searchPerson: sl()));
  //UseCases
  sl.registerLazySingleton(() => GetAllPersons(sl()));
  sl.registerLazySingleton(() => SearchPerson(sl()));
  //Repository
  sl.registerLazySingleton<PersonRepository>(() => PersonRepositoryImplement(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));
  sl.registerLazySingleton<PersonRemoteDataSource>(
      () => PersonRemoteDataSourceImplement(client: http.Client()));

  sl.registerLazySingleton<PersonLocalDataSource>(
      () => PersonLocalDataSourceImplement(sharedPreferences: sl()));
  //Core or Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImplement(sl()));
  //External dep
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
