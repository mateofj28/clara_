import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local_expense_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expense_summary_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import '../../presentation/bloc/expense_bloc.dart';

// Service Locator simple
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not found');
    }
    return service as T;
  }

  void register<T>(T service) {
    _services[T] = service;
  }
}

final sl = ServiceLocator();

Future<void> initializeDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.register<SharedPreferences>(sharedPreferences);

  // Data sources
  sl.register<LocalExpenseDataSource>(
    LocalExpenseDataSourceImpl(sharedPreferences: sl.get<SharedPreferences>()),
  );

  // Repositories
  sl.register<ExpenseRepository>(
    ExpenseRepositoryImpl(localDataSource: sl.get<LocalExpenseDataSource>()),
  );

  // Use cases
  sl.register<AddExpenseUseCase>(
    AddExpenseUseCase(sl.get<ExpenseRepository>()),
  );

  sl.register<GetExpenseSummaryUseCase>(
    GetExpenseSummaryUseCase(sl.get<ExpenseRepository>()),
  );

  sl.register<UpdateExpenseUseCase>(
    UpdateExpenseUseCase(sl.get<ExpenseRepository>()),
  );

  sl.register<DeleteExpenseUseCase>(
    DeleteExpenseUseCase(sl.get<ExpenseRepository>()),
  );

  // Bloc
  sl.register<ExpenseBloc>(
    ExpenseBloc(
      addExpenseUseCase: sl.get<AddExpenseUseCase>(),
      getExpenseSummaryUseCase: sl.get<GetExpenseSummaryUseCase>(),
      updateExpenseUseCase: sl.get<UpdateExpenseUseCase>(),
      deleteExpenseUseCase: sl.get<DeleteExpenseUseCase>(),
    ),
  );
}
