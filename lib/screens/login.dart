import 'package:flutter/material.dart';
// screens/login_screen.dart
// import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/screens/home.dart';
import '../blocs/login/login_bloc.dart';
import '../blocs/login/login_event.dart';
import '../blocs/login/login_state.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(AuthService())..add(LoginStarted()),
      child: Scaffold(
        appBar: AppBar(title: Text("Login")),
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(),
                ),
              );
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
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: "Username"),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      constraints: BoxConstraints(maxWidth: 500),
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: "Password"),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<LoginBloc>().add(
                          LoginSubmitted(
                            _usernameController.text,
                            _passwordController.text,
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
    );
  }
}