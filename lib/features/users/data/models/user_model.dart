import 'package:core_sim_ia/features/users/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  UserEntity toEntity() {
    return UserEntity(id: id, name: name, email: email);
  }

  @override
  List<Object?> get props => [id, name, email];
}
