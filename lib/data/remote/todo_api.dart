import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/data/remote/result/api_error.dart';

import '../memory/vo_todo.dart';
import '../simple_result.dart';
import '../todo_repository.dart';

///Remote DB
class TodoApi implements TodoRepository<ApiError> {
  //서버에서 Content-Type : application/json 헤더를 주지 않는 경우 아래 처럼 강제 변환 가능
  //final client = TodoClient(Dio()..interceptors.add(DioJsonResponseConverter()));
  final client = Dio(BaseOptions(baseUrl: Platform.isAndroid ? 'http://10.0.2.2:8080/' : 'http://localhost:8080/'));

  TodoApi._();

  static TodoApi instance = TodoApi._();

  @override
  Future<SimpleResult<List<Todo>, ApiError>> getTodoList() async {
    return tryRequest(() async {
      await sleepAsync(1.seconds);
      final todoList = await client.get<List>('todos');
      return SimpleResult.success(todoList.data?.map((e) => Todo.fromJson(e)).toList());
    });
  }

  @override
  Future<SimpleResult<void, ApiError>> addTodo(Todo todo) async {
    return tryRequest(() async {
      await client.post('todos', data: todo.toJson());
      return SimpleResult.success();
    });
  }

  @override
  Future<SimpleResult<void, ApiError>> updateTodo(Todo todo) async {
    return tryRequest(() async {
      await client.put('todos/${todo.id}', data: todo.toJson());
      return SimpleResult.success();
    });
  }

  @override
  Future<SimpleResult<void, ApiError>> removeTodo(int id) async {
    return tryRequest(() async {
      await client.delete('todos/$id');
      return SimpleResult.success();
    });
  }

  Future<SimpleResult<T, ApiError>> tryRequest<T>(
      Future<SimpleResult<T, ApiError>> Function() apiLogic) async {
    try {
      return await apiLogic();
    }  catch (e) {
      return  ApiError.createErrorResult(e);
    }
  }
}
