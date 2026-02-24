import '../data/model.dart';

class LoginState {}
class LoggedIn extends LoginState{
  User user;
  LoggedIn({required this.user});
}

class LoginError extends LoginState{
  String error;
  LoginError({required this.error});
}
class LogOut extends LoginState{}
class LoginLoading extends LoginState{}
class CreateAccount extends LoginState{}