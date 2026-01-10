import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herbal_garden_app/theme_based/homepage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showError("Account created successfully!");

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Sign up failed";
      if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        message = "Password must be at least 6 characters.";
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
        backgroundColor: _accentGreen.withValues(alpha: 0.8),
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
        decoration: BoxDecoration(gradient: _mainBackgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white, size: screenWidth * 0.15),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "Create Account",
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.08,
                    ),
                  ),
                  Text(
                    "Join the herbal community today",
                    style: GoogleFonts.interTight(
                      color: _secondaryTextGrey,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [Color(0x1AFFFFFF), Color(0x33FFFFFF)],
                        stops: [0, 1],
                        begin: AlignmentDirectional(0, -1),
                        end: AlignmentDirectional(0, 1),
                      ),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 20,
                            offset: Offset(0, 8))
                      ],
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
                            isVisible: _isPasswordVisible,
                            onVisibilityToggle: () => setState(
                                    () => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hintText: "Confirm Password",
                            icon: Icons.lock_reset_rounded,
                            screenWidth: screenWidth,
                            isPassword: true,
                            isVisible: _isConfirmPasswordVisible,
                            onVisibilityToggle: () => setState(() =>
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible),
                          ),
                          SizedBox(height: screenHeight * 0.04),

                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.065,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentGreen,
                                foregroundColor: Colors.white,
                                shadowColor: _accentGreen.withValues(alpha: 0.4),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                height: screenWidth * 0.06,
                                width: screenWidth * 0.06,
                                child: const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3),
                              )
                                  : Text(
                                "Sign Up",
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
                        "Already have an account? ",
                        style: GoogleFonts.interTight(
                            color: _secondaryTextGrey,
                            fontSize: screenWidth * 0.04),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Log In",
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
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !isVisible : false,
        style: GoogleFonts.interTight(
            color: Colors.white, fontSize: screenWidth * 0.04),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
          GoogleFonts.interTight(color: _secondaryTextGrey.withValues(alpha: 0.7)),
          prefixIcon: Icon(icon,
              color: Colors.white.withValues(alpha: 0.7), size: screenWidth * 0.055),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white.withValues(alpha: 0.7),
              size: screenWidth * 0.055,
            ),
            onPressed: onVisibilityToggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenWidth * 0.04),
        ),
      ),
    );
  }
}