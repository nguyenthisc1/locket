import 'package:flutter/material.dart';

import '../widgets/email_login_form.dart';
import '../widgets/phone_login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Email'), Tab(text: 'Số điện thoại')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // EmailLoginForm(), PhoneLoginForm()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
