//dart
import 'dart:io';
//packages
import 'package:flutter/material.dart';
//pickers
import '../pickers/user_image_picker.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String? username, //username is null in login case
    File? imageFile, //imageFile is null in login case
    String password,
    bool isLogin,
  ) submitFunction;
  final bool isLoading;
  const AuthForm({
    Key? key,
    required this.submitFunction,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String? _userEmail;
  String? _username;
  String? _userPassword;
  File? _userImageFile;
  final TextEditingController _passwordController = TextEditingController();

  void _pickedImage(File imageFile) {
    _userImageFile = imageFile;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please choose an image for your avatar."),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      //would trigger the onSave function of each TextFormField
      FocusScope.of(context).unfocus();
      //FocusScope is used to close the softkeyboard if it's still open after we submit the form
      //since it would move the focus out of any input field
      widget.submitFunction(
        (_userEmail as String).trim(),
        (_username == null) ? null : (_username as String).trim(),
        //_username is null when in login mode, just put in dummy data "" (if its type is String)
        //or null (if its type is String?)
        //or else an error would occur (type Null is not a subtype of type String)
        //we should use String? for _username
        (_userImageFile == null) ? null : (_userImageFile as File),
        (_userPassword as String).trim(),
        _isLogin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              onChanged: () {},
              child: Column(
                //MainAxisSize.min: Column only takes as much height as needed
                //MainAxisSize.max: Column only takes as much height as possible
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isLogin) UserImagePicker(_pickedImage),
                  TextFormField(
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    key: const ValueKey('email'),
                    validator: (inputValue) {
                      if (inputValue == null ||
                          inputValue.isEmpty ||
                          inputValue.contains('@') == false) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email address",
                    ),
                    onSaved: (inputValue) {
                      _userEmail = inputValue;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.words,
                      enableSuggestions: false,
                      key: const ValueKey('username'),
                      validator: (inputValue) {
                        if (inputValue == null || inputValue.isEmpty || inputValue.length < 4) {
                          return "Please enter at least 4 characters.";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "Username",
                      ),
                      onSaved: (inputValue) {
                        _username = inputValue;
                      },
                    ),
                  TextFormField(
                    key: const ValueKey('password'),
                    controller: _passwordController,
                    validator: (inputValue) {
                      if (inputValue == null || inputValue.isEmpty || inputValue.length < 7) {
                        return "Password must be at least 7 character long.";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Password",
                    ),
                    obscureText: true, //for hiding password
                    onSaved: (inputValue) {
                      _userPassword = inputValue;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (!_isLogin)
                    TextFormField(
                      key: const ValueKey('confirmPassword'),
                      //enabled: !_isLogin,
                      decoration: const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: !_isLogin
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  const SizedBox(height: 12),
                  if (widget.isLoading) const CircularProgressIndicator(),
                  if (!widget.isLoading)
                    ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      onPressed: _trySubmit,
                      child: Text(_isLogin ? "Login" : "Signup"),
                    ),
                  if (!widget.isLoading)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin ? "Create a new account" : "I already have an account"),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
