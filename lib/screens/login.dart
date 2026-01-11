import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import '../blocs/login/login_bloc.dart';
import '../services/auth_service.dart';
import 'package:ponit_of_sales/widgets/server_config_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _configKey = 0;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();
  void _handleLoginSuccess(BuildContext context) {
    // بعد الحصول على التوكن من الخادم بنجاح:
    BlocProvider.of<AuthBloc>(context).add(LoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      key: ValueKey(_configKey), // Recreates Bloc/Service when key changes
      create: (_) => LoginBloc(AuthService()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.login),
          actions: [
            ServerConfigButton(onSaved: () => setState(() => _configKey++)),
          ],
        ),
        body: SingleChildScrollView(
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state.status == LoginStatus.success) {
                _handleLoginSuccess(context);
              }
              if (state.status == LoginStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? l10n.loginFailed),
                  ),
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
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Text(
                              l10n.login,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(16.0),
                              constraints: BoxConstraints(maxWidth: 500),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: "Username",
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(16.0),
                              constraints: BoxConstraints(maxWidth: 500),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                ),
                                obscureText: true,
                              
                              ),

                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  context.read<LoginBloc>().add(
                                    LoginSubmitted(
                                      _usernameController.text,
                                      _passwordController.text,
                                    ),
                                  );
                                }
                              },
                              child: Text(l10n.login),
                            ),
                          ],
                        ),
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
