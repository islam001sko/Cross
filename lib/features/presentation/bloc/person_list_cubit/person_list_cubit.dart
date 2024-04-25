import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/domain/entities/person_entity.dart';
import 'package:rick_and_morty/features/domain/usecases/get_all_persons.dart';
import 'package:rick_and_morty/features/presentation/bloc/person_list_cubit/person_list_state.dart';

import '../../../../core/error/failure.dart';

class PersonListCubit extends Cubit<PersonState> {
  final GetAllPersons getAllPersons;
  PersonListCubit({required this.getAllPersons}) : super(PersonEmpty());

  int page = 1;

  void loadPerson() async {
    if (state is PersonLoading) {
      return;
    }

    final currentState = state;
    var oldPerson = <PersonEntity>[];

    if (currentState is PersonLoaded) {
      oldPerson = currentState.personsList;
    }

    emit(PersonLoading(oldPerson, isFirstFetch: page == 1));

    final failureOrPerson = await getAllPersons(PagePersonParams(page: page));

    failureOrPerson.fold(
        (failure) => emit(PersonError(message: _mapFailureToMessage(failure))),
        (character) {
      page++;
      final persons = (state as PersonLoading).oldPersonsList;
      persons!.addAll(character);
      emit(PersonLoaded(persons));
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'ServerFailure';
      case CacheFailure:
        return 'CacheFailure';
      default:
        return 'UnexpectedFailure';
    }
  }
}
