import 'package:audiobook/login/data/model.dart';

class Loginevent {}
class Login extends Loginevent{
  User user;
  Login({required this.user});
}class Logout extends Loginevent{
  User user;
  Logout({required this.user});
}
class CreateAccountEvent extends Loginevent{
  User user;
  CreateAccountEvent({required this.user});
}
class ToggleLogin extends Loginevent{}