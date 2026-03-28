import 'package:flutter/material.dart';
import 'package:marooneen_dashboard/auth/components/email_widget.dart';
import 'package:marooneen_dashboard/auth/components/icon_widget.dart';
import 'package:marooneen_dashboard/auth/components/password_widget.dart';
import 'package:marooneen_dashboard/pages/sidebar.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 560,
          width: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 56),
            child: Column(
              children: [
                IconWidget(),
                SizedBox(height: 16),
                EmailWidget(controller: TextEditingController()),
                SizedBox(height: 16),
                PasswordInput(controller: TextEditingController()),
                SizedBox(height: 24),
                ShadButton(
                  child: Text('Login'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LandingScreen(),
                      ),
                    );
                  },
                  width: double.infinity,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    SizedBox(width: 16),
                    Text('Or'),
                    SizedBox(width: 16),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 8),
                ShadButton.outline(
                  child: Text('Register'),
                  onPressed: () {},
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
