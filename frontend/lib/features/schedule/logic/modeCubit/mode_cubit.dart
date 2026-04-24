import 'package:flutter_bloc/flutter_bloc.dart';
import 'mode_state.dart';

class ModeCubit extends Cubit<ModeState> {
  ModeCubit() : super(const ModeState(''));

  void selectMode(String mode) {
    emit(ModeState(mode));
  }
}