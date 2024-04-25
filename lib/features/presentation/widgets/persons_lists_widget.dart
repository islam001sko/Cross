import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/domain/entities/person_entity.dart';
import 'package:rick_and_morty/features/presentation/bloc/person_list_cubit/person_list_cubit.dart';
import 'package:rick_and_morty/features/presentation/bloc/person_list_cubit/person_list_state.dart';
import 'package:rick_and_morty/features/presentation/widgets/person_card_widget.dart';

class PersonsList extends StatefulWidget {
  PersonsList({super.key});

  @override
  State<PersonsList> createState() => _PersonsListState();
}

class _PersonsListState extends State<PersonsList> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    context.read<PersonListCubit>().loadPerson();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final thresholdReached = scrollController.position.atEdge &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent;
    final isLoading = context.read<PersonListCubit>().state is PersonLoading;

    if (thresholdReached && !isLoading) {
      context.read<PersonListCubit>().loadPerson();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonListCubit, PersonState>(
      builder: (context, state) {
        List<PersonEntity> persons = [];
        bool isLoading = false;

        if (state is PersonLoading && state.isFirstFetch!) {
          return _loadingIndicator();
        } else if (state is PersonLoading) {
          persons = state.oldPersonsList!;
          print("ww");
          isLoading = true;
        } else if (state is PersonLoaded) {
          persons = state.personsList;
        } else if (state is PersonError) {
          return Text(
            state.message!,
            style: TextStyle(color: Colors.white, fontSize: 25),
          );
        }

        return ListView.separated(
          controller: scrollController,
          itemBuilder: (context, index) {
            if (index < persons.length) {
              return PersonCard(person: persons[index]);
            } else {
              return _loadingIndicator();
            }
          },
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey[400]),
          itemCount: persons.length + (isLoading ? 1 : 0),
        );
      },
    );
  }

  Widget _loadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
