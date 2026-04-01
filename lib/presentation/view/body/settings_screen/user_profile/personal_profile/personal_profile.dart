import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/data/models/profile/profile_model.dart';
import 'package:orka_sports/presentation/widgets/custom_textfield.dart';
import 'package:orka_sports/presentation/widgets/phone_number_widget.dart';
import 'dart:io';

import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';

class PersonalProfile extends StatefulWidget {
  const PersonalProfile({super.key});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  // final TextEditingController dobController = TextEditingController();
  // final TextEditingController ageController = TextEditingController();
  String phoneCode = '+91';
  String? selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        // Check file extension
        final allowedExtensions = ['jpg', 'jpeg', 'png'];
        final ext = image.path.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(ext)) {
          showCustomSnackbar(context, 'Only JPG and PNG images are allowed.');

          return;
        }
        setState(() {
          selectedImagePath = image.path;
        });
      }
    } catch (e) {
      showCustomSnackbar(context, 'Error picking image: $e');
    }
  }

  @override
  void initState() {
    // ✅ NEW WAY - Only call if not already loaded
if (context.read<ProfileBloc>().state is! ProfileLoaded) {
  context.read<ProfileBloc>().add(LoadProfile());
}

    super.initState();
  }

  // Future<void> _selectDate() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate:
  //         dobController.text.isNotEmpty
  //             ? DateTime.parse(dobController.text.split('/').reversed.join('-'))
  //             : DateTime.now(),
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime.now(),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: ColorScheme.light(
  //             primary: AppColors.primary,
  //             onPrimary: Colors.white,
  //             surface: Colors.white,
  //             onSurface: Colors.black,
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       dobController.text =
  //           "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
  //     });
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      nameController.text = state.profile.name;
      emailController.text = state.profile.email;
      phoneController.text = state.profile.mobile ?? '';
      phoneCode = state.profile.phonecode ?? '+91';
      log('Phone code: $phoneCode');
      log('Phone number: ${state.profile.mobile}');
      // if (state.profile.dob != null && state.profile.dob!.isNotEmpty) {
      //   dobController.text = state.profile.dob!;
      // }
      if (state.profile.profileImage != null && state.profile.profileImage!.isNotEmpty) {
        setState(() {
          selectedImagePath = state.profile.profileImage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          showCustomSnackbar(context, 'Profile updated successfully');
          Navigator.pop(context); // Pop back to settings screen
          context.read<ProfileBloc>().add(LoadProfile()); // Reload profile data
        } else if (state is ProfileError) {
          showCustomSnackbar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            ProfileData? profile;
            bool isUpdating = false;

            if (state is ProfileLoaded) {
              profile = state.profile;
            } else if (state is ProfileUpdating) {
              profile = state.profile;
              isUpdating = true;
            } else if (state is ProfileUpdated) {
              profile = state.profile;
            }

            if (profile == null) {
              return Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: selectedImagePath != null
                                    ? selectedImagePath!.startsWith('http')
                                        ? Image.network(
                                            selectedImagePath!,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return SizedBox(
                                                width: 90,
                                                height: 90,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            (loadingProgress.expectedTotalBytes ?? 1)
                                                        : null,
                                                    strokeWidth: 2,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Image.asset(
                                                'assets/images/ff1.png',
                                                width: 90,
                                                height: 90,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.file(
                                            File(selectedImagePath!),
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          )
                                    : Image.asset(
                                        'assets/images/ff1.png',
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomTextfield(
                            controller: nameController,
                            hintText: 'Enter your name',
                            labelText: 'Name',
                            isPassword: false,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomTextfield(
                            controller: emailController,
                            hintText: 'Email',
                            labelText: 'Email',
                            isPassword: false,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PhoneNumberWidget(
                            controller: phoneController,
                            onPhoneCodeChanged: (code) {
                              setState(() {
                                phoneCode = code;
                              });
                            },
                            initialPhoneCode: phoneCode,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: TextField(
                        //     controller: dobController,
                        //     readOnly: true,
                        //     decoration: InputDecoration(
                        //       hintText: 'DD/MM/YYYY',
                        //       labelText: 'Date of Birth',
                        //       prefixIcon: const Icon(
                        //         Icons.calendar_today,
                        //         color: AppColors.primary,
                        //       ),
                        //       border: InputBorder.none,
                        //     ),
                        //     onTap: _selectDate,
                        //   ),
                        // ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: AppColors.primary,
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isUpdating
                                ? null
                                : () {
                                    if (nameController.text.trim().isEmpty) {
                                      showCustomSnackbar(
                                        context,
                                        'Please enter your name',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    if (emailController.text.trim().isEmpty) {
                                      showCustomSnackbar(
                                        context,
                                        'Please enter your email',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    if (phoneController.text.trim().isEmpty) {
                                      showCustomSnackbar(
                                        context,
                                        'Please enter your phone number',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    // if (dobController.text.trim().isEmpty) {
                                    //   showCustomSnackbar(context, 'Please select your date of birth', isError: true);
                                    //   return;
                                    // }

                                    final updatedProfile = profile!.copyWith(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      mobile: phoneController.text.trim(),
                                      phonecode: phoneCode,
                                      // dob: dobController.text.trim(),
                                      profileImage: selectedImagePath,
                                    );

                                    context.read<ProfileBloc>().add(
                                          UpdateProfile(updatedProfile),
                                        );
                                  },
                            child: isUpdating
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    // dobController.dispose();
    // ageController.dispose();
    super.dispose();
  }
}
