import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock, size: 64, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  "Login to your Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: true, onChanged: (_) {}),
                        const Text("Remember me"),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Forgot Password?"),
                    )
                  ],
                ),

                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: const Text("Sign in"),
                ),

                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: const Text("Sign Up"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
