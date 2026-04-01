import 'package:orka_sports/presentation/view/home/data/models/get_allpartners_model.dart';
import 'package:orka_sports/presentation/view/home/data/models/get_allusers_model.dart';

abstract class HomeRepo {
  // Repo function to get all the users
  Future<GetAllUsersModel> getAllUsersRepo();
  // Repo function to get all the partners
  Future<GetAllPartnersModel> getAllPartnersRepo({required Map<String, dynamic> data});
}
