import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import 'category_event.dart';
import 'category_state.dart';

@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc(
    this.getCategoriesUseCase,
    this.createCategoryUseCase,
    this.updateCategoryUseCase,
    this.deleteCategoryUseCase,
  ) : super(const CategoryState()) {
    on<LoadCategories>(_onLoad);
    on<CreateCategory>(_onCreate);
    on<UpdateCategory>(_onUpdate);
    on<DeleteCategory>(_onDelete);
  }

  Future<void> _onLoad(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await getCategoriesUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (categories) => emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: categories
              .map((name) => CategoryEntity(name: name))
              .toList(),
        ),
      ),
    );
  }

  Future<void> _onCreate(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await createCategoryUseCase(event.name);
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadCategories());
      },
    );
  }

  Future<void> _onUpdate(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await updateCategoryUseCase(
      UpdateCategoryParams(event.oldName, event.newName),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadCategories());
      },
    );
  }

  Future<void> _onDelete(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await deleteCategoryUseCase(event.name);
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadCategories());
      },
    );
  }
}
