import 'package:expange/scoped_model/commonmodel.dart';
import 'package:expange/scoped_model/locationmodel.dart';
import 'package:expange/scoped_model/usermodel.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model with CommonModel, UserModel, LocationModel {}
