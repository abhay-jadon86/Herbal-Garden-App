import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herbal_garden_app/theme_based/homepage.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final Color _accentGreen = const Color(0xFF32CD32);
  final Color _secondaryTextGrey = const Color(0xFF95A1AC);
  final Gradient _mainBackgroundGradient = const LinearGradient(
    colors: [Color(0xFF4B0082), Color(0xFF008080), Color(0xFF20B2AA)],
    stops: [0.3, 0.8, 1],
    begin: AlignmentDirectional(1, 1),
    end: AlignmentDirectional(-1, -1),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage())
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password provided.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is badly formatted.";
      } else if (e.code == 'network-request-failed') {
        message = "Check your internet connection.";
      }
      _showError(message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError("Please enter your email address first to reset your password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset link sent! Check your inbox."),
            backgroundColor: Color(0xFF32CD32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'invalid-email') {
        message = "The email address is badly formatted.";
      } else if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      }
      _showError(message ?? e.message ?? "Failed to send reset email");
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Enter email and password to create account");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showError("Account created! Logging you in...");

      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage())
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Sign up failed";
      if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        message = "Password should be at least 6 characters.";
      }
      _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _mainBackgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: screenWidth * 0.15,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Text(
                    "Welcome Back",
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.08,
                    ),
                  ),
                  Text(
                    "Sign in to your herbal garden",
                    style: GoogleFonts.interTight(
                      color: _secondaryTextGrey,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [Color(0x1AFFFFFF), Color(0x33FFFFFF)],
                        stops: [0, 1],
                        begin: AlignmentDirectional(0, -1),
                        end: AlignmentDirectional(0, 1),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hintText: "Email Address",
                            icon: Icons.email_outlined,
                            screenWidth: screenWidth,
                          ),
                          SizedBox(height: screenHeight * 0.025),

                          _buildTextField(
                            controller: _passwordController,
                            hintText: "Password",
                            icon: Icons.lock_outline_rounded,
                            screenWidth: screenWidth,
                            isPassword: true,
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                                onTap: _isLoading ? null : _handleForgotPassword,
                              child: Text(
                                "Forgot Password?",
                                style: GoogleFonts.interTight(
                                  color: _secondaryTextGrey,
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),

                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.065,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentGreen,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shadowColor: _accentGreen.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                height: screenWidth * 0.06,
                                width: screenWidth * 0.06,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                                  : Text(
                                "Log In",
                                style: GoogleFonts.interTight(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.interTight(
                          color: _secondaryTextGrey,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpPage())
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.interTight(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double screenWidth,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        style: GoogleFonts.interTight(
          color: Colors.white,
          fontSize: screenWidth * 0.04,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.interTight(
            color: _secondaryTextGrey.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.7),
            size: screenWidth * 0.055,
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white.withValues(alpha: 0.7),
              size: screenWidth * 0.055,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.04,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1),
          ),
        ),
      ),
    );
  }
}