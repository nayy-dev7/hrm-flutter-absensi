
import 'package:flutter/material.dart';
// import 'inputpegawai.dart';
import 'dashboard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi/config/config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}

class AppColors {
  static const one = Color(0xff0d6efd);
  static const dark = Color.fromARGB(255, 5, 36, 82);
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.one,
              AppColors.dark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(
                    24),
            child: Column(
              children: [
                const Align(
                  alignment:
                      Alignment
                          .topRight,
                  child: Icon(
                    Icons.more_horiz,
                    color:
                        Colors.white,
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons
                      .badge,
                  color:
                      Colors.white,
                  size: 90,
                ),

                const SizedBox(
                    height: 12),

                const Text(
                  'ABC COMPANY ATTENDANCE',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 28,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),

                const SizedBox(
                    height: 60),

                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 40,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                    height: 36),

                _outlineButton(
                  context,
                  'SIGN IN',
                  const SignInPage(),
                ),

                const SizedBox(
                    height: 16),

                _solidButton(
                  context,
                  'SIGN UP',
                  const SignUpPage(),
                ),

                const Spacer(),

                const Text(
                  'Login with Social Media',
                  style: TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),

                const SizedBox(
                    height: 16),

                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Colors.white,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 14),
                    CircleAvatar(
                      backgroundColor:
                          Colors.white,
                      child: Icon(
                        Icons.flutter_dash,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 14),
                    CircleAvatar(
                      backgroundColor:
                          Colors.white,
                      child: Icon(
                        Icons.facebook,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _outlineButton(
    BuildContext context,
    String text,
    Widget page,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: () =>
            Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => page,
          ),
        ),
        style:
            OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Colors.white,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    32),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color:
                Colors.white,
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget _solidButton(
    BuildContext context,
    String text,
    Widget page,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: () =>
            Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => page,
          ),
        ),
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              Colors.white,
          foregroundColor:
              Colors.black,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    32),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPage(
      title:
          'Hello, Sign in!',
      button: 'SIGN IN',
      isSignUp: false,
    );
  }
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPage(
      title:
          'Create Your Account',
      button: 'SIGN UP',
      isSignUp: true,
    );
  }
}

class AuthPage extends StatefulWidget {
  final String title;
  final String button;
  final bool isSignUp;

  const AuthPage({
    super.key,
    required this.title,
    required this.button,
    required this.isSignUp,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            colors: [
              AppColors.one,
              AppColors.dark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              Padding(
                padding:
                    const EdgeInsets
                        .all(24),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [

                    Text(
                      widget.title,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const Icon(
                      Icons.more_horiz,
                      color:
                          Colors.white,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .all(28),
                  decoration:
                      const BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius.only(
                      topLeft:
                          Radius.circular(
                              40),
                      topRight:
                          Radius.circular(
                              40),
                    ),
                  ),
                  child: Column(
                    children: [

                      if (widget.isSignUp)
                        const TextField(
                          decoration:
                              InputDecoration(
                            labelText:
                                'Full Name',
                          ),
                        ),

                      if (widget.isSignUp)
                        const SizedBox(
                            height:
                                16),

                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),

                      const SizedBox(
                          height: 16),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                      ),

                      if (widget.isSignUp)
                        const SizedBox(
                            height:
                                16),

                      if (widget.isSignUp)
                        TextField(
                          controller: confirmPasswordController,
                          obscureText:
                              true,
                          decoration:
                              InputDecoration(
                            labelText:
                                'Confirm Password',
                          ),
                        ),

                      const SizedBox(
                          height: 30),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 56,
                        child:
                            ElevatedButton(
                          onPressed:
                              () async {

                            if (widget.isSignUp) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          const SignInPage(),
                                ),
                              );
                            } else {

                              final response = await http.post(
                                Uri.parse(
                                  "${ApiConfig.baseUrl}/login",
                                ),
                                body: {
                                  "email": emailController.text,
                                  "password": passwordController.text,
                                },
                              );

                              final data = jsonDecode(response.body);

                              if (data["success"] == true) {

                                final employee = data["employee"];

                                print(employee);

                                final prefs =
                                    await SharedPreferences.getInstance();

                                await prefs.setInt(
                                  "employee_id",
                                  employee["id"],
                                );

                                await prefs.setString(
                                  "nama",
                                  employee["nama"] ?? "",
                                );

                                await prefs.setString(
                                  "email",
                                  employee["email"] ?? "",
                                );

                                await prefs.setString(
                                  "nip",
                                  employee["nip"] ?? "",
                                );

                                await prefs.setString(
                                  "role",
                                  employee["role"] ?? "",
                                );

                                await prefs.setString(
                                  "hp",
                                  employee["phone"] ?? "",
                                );

                                await prefs.setString(
                                  "address",
                                  employee["alamat"] ?? "",
                                );

                                await prefs.setString(
                                  "division",
                                  employee["divisi"] ?? "",
                                );

                                await prefs.setString(
                                  "joinDate",
                                  employee["join_date"] ?? "",
                                );

                                await prefs.setString(
                                  "foto",
                                  employee["foto"] ?? "",
                                );

                                print(employee);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const MainDashboard(),
                                  ),
                                );

                              } else {

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      data["message"],
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child:
                              Text(widget.button),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}