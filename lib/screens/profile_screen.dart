import 'package:flutter/material.dart';

import '../widgets/profile_avatar.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/gradient_button.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../services/session_service.dart';
import '../services/image_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _hidePassword = true;
  User? currentUser;

  bool isLoading = true;

  String? imagePath;

  @override
  void initState() {
    super.initState();
    loadUser();
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    final id =
        await SessionService.instance.getUserId();

    if (id == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final user =
        await DatabaseHelper.instance.getUserById(id);

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    _nameController.text = user.name;
    _emailController.text = user.email;

    imagePath = user.photo;
    currentUser = user;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveProfile() async {
    if (currentUser == null) return;

    final updatedUser = currentUser!.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim().isEmpty
          ? currentUser!.password
          : _passwordController.text.trim(),
      photo: imagePath,
    );

    await DatabaseHelper.instance.updateUser(updatedUser);

    currentUser = updatedUser;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Profil mis à jour avec succès.",
        ),
      ),
    );
  }

  Future<void> _changePhoto() async {
    if (currentUser == null) return;

    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              const ListTile(
                title: Center(
                  child: Text(
                    "Changer la photo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Galerie"),
                onTap: () =>
                    Navigator.pop(context, "gallery"),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Caméra"),
                onTap: () =>
                    Navigator.pop(context, "camera"),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Annuler"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );

    String? path;

    if (choice == "gallery") {
      path = await ImageService.instance
          .pickImageFromGallery();
    }

    if (choice == "camera") {
      path = await ImageService.instance
          .pickImageFromCamera();
    }

    if (path == null) return;

    final updatedUser = currentUser!.copyWith(
      photo: path,
    );

    await DatabaseHelper.instance.updateUser(
      updatedUser,
    );

    setState(() {
      currentUser = updatedUser;
      imagePath = path;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Photo de profil mise à jour.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon profil"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 10),

              ProfileAvatar(
                imagePath: imagePath,
                onTap: _changePhoto,
              ),

              const SizedBox(height: 35),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      CustomTextField(
                        controller:
                            _nameController,
                        hintText:
                            "Nom complet",
                        prefixIcon:
                            Icons.person,
                      ),

                      const SizedBox(height: 20),

                      CustomTextField(
                        controller:
                            _emailController,
                        hintText:
                            "Adresse email",
                        prefixIcon:
                            Icons.email,
                        keyboardType:
                            TextInputType
                                .emailAddress,
                      ),

                      const SizedBox(height: 20),

                      CustomTextField(
                        controller:
                            _passwordController,
                        hintText:
                            "Nouveau mot de passe",
                        prefixIcon:
                            Icons.lock,
                        obscureText:
                            _hidePassword,

                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword =
                                  !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons
                                    .visibility_off
                                : Icons
                                    .visibility,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      GradientButton(
                        text:
                            "Enregistrer",
                        icon:
                            Icons.save,
                        onPressed: saveProfile,
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