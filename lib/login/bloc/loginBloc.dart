import 'package:audiobook/login/bloc/loginEvent.dart';
import 'package:audiobook/login/bloc/loginState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<Loginevent,LoginState>{
  LoginBloc() : super(LoginLoading()){
    on<Login>((event, emit) => emit(LoggedIn(user: event.user)));
    on<Logout>((event, emit) => emit(LogOut()));
    on<ToggleLogin>((_,_)=>emit(CreateAccount()));
  }
}