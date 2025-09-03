import 'package:flutter/material.dart';
import '../widgets/profile_form.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: ProfileForm(),
      ),
    );
  }
}
