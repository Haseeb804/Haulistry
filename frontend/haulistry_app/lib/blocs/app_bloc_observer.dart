import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

/// Observer to monitor all BLoC state changes and events
/// Only active in debug mode for development and debugging
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      debugPrint('✅ BLoC Created: ${bloc.runtimeType}');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('🔄 BLoC Changed: ${bloc.runtimeType}');
      debugPrint('   Current State: ${change.currentState}');
      debugPrint('   Next State: ${change.nextState}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ BLoC Error: ${bloc.runtimeType}');
      debugPrint('   Error: $error');
      debugPrint('   StackTrace: $stackTrace');
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      debugPrint('🔴 BLoC Closed: ${bloc.runtimeType}');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      debugPrint('📨 Event Added: ${event.runtimeType} to ${bloc.runtimeType}');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('🔀 Transition: ${bloc.runtimeType}');
      debugPrint('   Event: ${transition.event.runtimeType}');
      debugPrint('   Current State: ${transition.currentState}');
      debugPrint('   Next State: ${transition.nextState}');
    }
  }
}
