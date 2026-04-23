import 'package:flutter_bloc/flutter_bloc.dart';

class SearchState {
  final bool isSearching;
  final String query;

  SearchState({this.isSearching = false, this.query = ''});

  SearchState copyWith({bool? isSearching, String? query}) {
    return SearchState(
      isSearching: isSearching ?? this.isSearching,
      query: query ?? this.query,
    );
  }
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState());

  void toggleSearch() {
    emit(state.copyWith(isSearching: !state.isSearching, query: ''));
  }

  void updateQuery(String query) {
    emit(state.copyWith(query: query));
  }

  void clearSearch() {
    emit(state.copyWith(query: ''));
  }
  
  void closeSearch() {
    emit(state.copyWith(isSearching: false, query: ''));
  }
}
