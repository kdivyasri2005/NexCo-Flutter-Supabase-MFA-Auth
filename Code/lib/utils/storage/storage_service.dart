import 'package:get_storage/get_storage.dart';
import 'package:nexco/utils/storage/storage_keys.dart';


class StorageService{
  static final GetStorage session = GetStorage();
  static dynamic userSession = session.read(StorageKeys.userSession);
}

