// splash_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  void _onSplashStarted(SplashStarted event, Emitter<SplashState> emit) async {
    await Future.delayed(const Duration(seconds: 5));
    emit(SplashCompleted());
  }
}

abstract class SplashEvent {}

class SplashStarted extends SplashEvent {}

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashCompleted extends SplashState {}
