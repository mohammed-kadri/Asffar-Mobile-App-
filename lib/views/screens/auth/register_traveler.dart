import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/theme/app_theme.dart';

class RegisterTraveler extends StatefulWidget {
  const RegisterTraveler({super.key});

  @override
  State<RegisterTraveler> createState() => _RegisterTravelerState();
}

class _RegisterTravelerState extends State<RegisterTraveler> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screen_width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: SpinKitChasingDots(
                  color: AppTheme.lightTheme.primaryColor,
                  size: 50.0,
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 35),
                        // Logo
                        Image.asset(
                          'assets/images/main_logo.jpg',
                          height: 40,
                        ),
                        const SizedBox(height: 50),
                        // Arabic Text
                        Text(
                          'مرحبا بك في مجتمع المسافرين',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Name TextField
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B84FF).withOpacity(0.09),
                            borderRadius: BorderRadius.circular(screen_width),
                          ),
                          child: TextField(
                            controller: _nameController,
                            maxLines: 1,
                            maxLength: 30,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'الاسم الكامل',
                              counterText: '',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                              prefixIcon: Icon(Icons.person_outline, color: AppTheme.lightTheme.colorScheme.primary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14, bottom: 14, right: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                              counterText: '',
                              hintText: 'البريد الالكتروني',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.lightTheme.colorScheme.primary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14, bottom: 14, right: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Phone Number TextField
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B84FF).withOpacity(0.09),
                            borderRadius: BorderRadius.circular(screen_width),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            maxLines: 1,
                            maxLength: 11,
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'رقم الهاتف',
                              counterText: '',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                              prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.lightTheme.colorScheme.primary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14, bottom: 14, right: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Password TextField
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B84FF).withOpacity(0.09),
                            borderRadius: BorderRadius.circular(screen_width),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            maxLines: 1,
                            maxLength: 60,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'كلمة المرور',
                              counterText: '',
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
                              contentPadding: EdgeInsets.only(top: 14, bottom: 14, right: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Repeat Password TextField
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B84FF).withOpacity(0.09),
                            borderRadius: BorderRadius.circular(screen_width),
                          ),
                          child: TextField(
                            controller: _repeatPasswordController,
                            obscureText: _obscureRepeatPassword,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            maxLength: 60,
                            decoration: InputDecoration(
                              hintText: 'تأكيد كلمة المرور',
                              counterText: '',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.lightTheme.colorScheme.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureRepeatPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureRepeatPassword = !_obscureRepeatPassword;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14, bottom: 14, right: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    FocusScope.of(context).unfocus();
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    if (_passwordController.text == _repeatPasswordController.text &&
                                        _passwordController.text.length >= 6) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      try {
                                        await Provider.of<AuthProvider>(context, listen: false).register(
                                          _emailController.text,
                                          _nameController.text, // Sending name as ownerName
                                          '', // No agencyName for travelers
                                          _phoneController.text,
                                          _passwordController.text,
                                          'Traveler',
                                          context,
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'حدث خطأ أثناء التسجيل',
                                              textDirection: TextDirection.rtl,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      } finally {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        _passwordController.text.length >= 6
                                            ? SnackBar(
                                                content: Text(
                                                  'كلمة المرور غير متطابقة..',
                                                  textDirection: TextDirection.rtl,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                backgroundColor: Colors.redAccent,
                                              )
                                            : SnackBar(
                                                content: Text(
                                                  'كلمة المرور يجب أن تتكون من 6 حروف على الأقل..',
                                                  textDirection: TextDirection.rtl,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(screen_width),
                              ),
                            ),
                            child: Text(
                              'تسجيل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Register as Agency Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pushNamed(context, '/register_agency');
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(screen_width),
                                  side: BorderSide(
                                      color: AppTheme.lightTheme.colorScheme.primary.withAlpha(100)),
                                ),
                              ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: TextDirection.rtl,
                              children: [
                                Text(
                                  'أنشء حساب',
                                  style: TextStyle(
                                    color: Color(0XFF313131).withAlpha(100),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'كوكالة',
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
                        const SizedBox(height: 5),

                        Container(
                          height: 60,
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pushNamed(context, '/login_traveler');
                            },
                            hoverColor: Colors.transparent,
                            child: Text(
                              'لديك حساب بالفعل؟',
                              style: TextStyle(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom Part
            ],
          ),
        ],
      ),
    );
  }
}