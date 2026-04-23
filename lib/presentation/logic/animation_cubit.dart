import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnimationCubit extends Cubit<double> {
  Timer? _timer;

  AnimationCubit() : super(0.0);

  void startFadeIn({Duration duration = const Duration(milliseconds: 600)}) {
    const steps = 30;
    final interval = duration.inMilliseconds ~/ steps;
    int currentStep = 0;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      currentStep++;
      if (!isClosed) {
        emit(currentStep / steps);
      }
      if (currentStep >= steps) timer.cancel();
    });
  }

  void startPulse() {
    _timer?.cancel();
    bool growing = true;
    // Smoother pulse: 16ms (60fps) and smaller increments
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (growing) {
        double next = state + 0.005;
        if (next >= 1.05) {
          next = 1.05;
          growing = false;
        }
        emit(next);
      } else {
        double next = state - 0.005;
        if (next <= 0.95) {
          next = 0.95;
          growing = true;
        }
        emit(next);
      }
    });
  }

  void startFloat() {
    _timer?.cancel();
    bool goingUp = true;
    // Smoother float: 16ms (60fps) and smaller increments
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (goingUp) {
        double next = state + 0.15;
        if (next >= 8.0) {
          next = 8.0;
          goingUp = false;
        }
        emit(next);
      } else {
        double next = state - 0.15;
        if (next <= -8.0) {
          next = -8.0;
          goingUp = true;
        }
        emit(next);
      }
    });
  }

  void startShake() {
    _timer?.cancel();
    bool goingRight = true;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (goingRight) {
        double next = state + 0.8;
        if (next >= 5.0) {
          next = 5.0;
          goingRight = false;
        }
        emit(next);
      } else {
        double next = state - 0.8;
        if (next <= -5.0) {
          next = -5.0;
          goingRight = true;
        }
        emit(next);
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
