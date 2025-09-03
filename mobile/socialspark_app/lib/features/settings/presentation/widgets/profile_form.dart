import 'package:flutter/material.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: "John Doe");
    final emailController = TextEditingController(text: "john@gmail.com");

    return Column(
      children: [
        TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
        TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {}, child: const Text("Confirm"))
      ],
    );
  }
}
