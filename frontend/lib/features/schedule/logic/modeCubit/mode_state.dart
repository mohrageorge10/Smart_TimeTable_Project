import 'package:equatable/equatable.dart';

class ModeState extends Equatable {
  final String selectedMode;

  const ModeState(this.selectedMode);

  @override
  List<Object> get props => [selectedMode];
}