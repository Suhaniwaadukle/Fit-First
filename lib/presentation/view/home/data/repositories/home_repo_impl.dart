import 'dart:developer';

import 'package:orka_sports/core/utils/error_handling.dart';
import 'package:orka_sports/presentation/view/home/data/datasources/home_service.dart';
import 'package:orka_sports/presentation/view/home/data/models/get_allpartners_model.dart';
import 'package:orka_sports/presentation/view/home/data/models/get_allusers_model.dart';
import 'package:orka_sports/presentation/view/home/domain/repositories/home_repo.dart';

class HomeRepoImpl extends HomeService implements HomeRepo {
  //Repo function to get all users
  @override
  Future<GetAllUsersModel> getAllUsersRepo() async {
    try {
      final response = await getAllUsersService();
      GetAllUsersModel getAllUsersModel = GetAllUsersModel.fromJson(response.data);
      return getAllUsersModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to get all partners
  @override
  Future<GetAllPartnersModel> getAllPartnersRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getAllPartnersService(data: data);
      GetAllPartnersModel getAllPartnersModel = GetAllPartnersModel.fromJson(response.data);
      return getAllPartnersModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }
}
