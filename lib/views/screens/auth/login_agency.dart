import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/theme/app_theme.dart';

class LoginAgency extends StatefulWidget {
  const LoginAgency({super.key});

  @override
  State<LoginAgency> createState() => _LoginAgencyState();
}

class _LoginAgencyState extends State<LoginAgency> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screen_width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [

                        const SizedBox(height: 35),
                        // Logo
                        Image.asset(
                          'assets/images/main_logo.jpg', // Make sure to add your logo to assets
                          height: 40,
                        ),
                        const SizedBox(height: 80),
                        // Arabic Text
                        Text(
                          'سجل الدخول في حسابك و ابدأ بنشر',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                        Text(
                          'رحلاتك للمسافرين',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Email TextField
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B84FF).withOpacity(0.09),
                            borderRadius: BorderRadius.circular(screen_width),
                          ),
                          child: TextField(
                            controller: _emailController,
                            maxLines: 1,
                            maxLength: 35,
                            keyboardType: TextInputType.emailAddress,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'البريد الالكتروني',
                              counterText: '',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.lightTheme.colorScheme.primary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password TextField
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B84FF).withOpacity(0.09),
                            borderRadius: BorderRadius.circular(screen_width),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'كلمة المرور',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.lightTheme.colorScheme.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: Text(
                              'نسيت كلمة المرور ؟',
                              style: TextStyle(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              await Provider.of<AuthProvider>(context, listen: false).login(
                                _emailController.text,
                                _passwordController.text,
                                'Agency',
                                context,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(screen_width),
                              ),
                            ),
                            child: Text(
                              'سجل الدخول',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Login as Traveler Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              Navigator.pushNamed(context, '/login_traveler');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(screen_width),
                                side: BorderSide(color: AppTheme.lightTheme.colorScheme.primary.withAlpha(100)),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: TextDirection.rtl,
                              children: [
                                Text(
                                  'سجل الدخول',
                                  style: TextStyle(
                                    color: Color(0XFF313131).withAlpha(100),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'كمسافر',
                                  style: TextStyle(
                                    color: AppTheme.lightTheme.colorScheme.secondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    
                    // Google Login Button
                    Container(
                      height: 140,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pushNamed(context, '/register_agency');
                            },
                            hoverColor: Colors.transparent,
                            child: Text(
                              'ليس لديك حساب ؟',
                              style: TextStyle(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}