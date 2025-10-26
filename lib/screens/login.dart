import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
import '../blocs/login/login_bloc.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  // جزء من شاشة تسجيل الدخول (LoginScreen)
  // Make controllers non-final or initialize them in initState if this were a StatefulWidget
  // For a StatelessWidget, they should be local to the build method or passed as parameters.

  void _handleLoginSuccess(BuildContext context) {
    // بعد الحصول على التوكن من الخادم بنجاح:
    BlocProvider.of<AuthBloc>(context).add(LoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    return BlocProvider(
      create: (_) => LoginBloc(AuthService()),
      child: Scaffold(
        appBar: AppBar(title: Text("Login")),
        body: SingleChildScrollView(
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state.status == LoginStatus.success) {
                _handleLoginSuccess(context);
              }
              if (state.status == LoginStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage ?? "Login failed")),
                );
              }
            },
            builder: (context, state) {
              if (state.status == LoginStatus.loading) {
                return Center(child: CircularProgressIndicator());
              }

              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage("assets/logo/logo-no-background.png"),
                        fit: BoxFit.contain,
                        height: 100,
                        width: 110,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        constraints: BoxConstraints(maxWidth: 500),
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(labelText: "Username"),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        constraints: BoxConstraints(maxWidth: 500),
                        child: TextField(
                          controller: passwordController,
                          decoration: InputDecoration(labelText: "Password"),
                          obscureText: true,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LoginBloc>().add(
                            LoginSubmitted(
                              usernameController.text,
                              passwordController.text,
                            ),
                          );
                        },
                        child: Text("Login"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
