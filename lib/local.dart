import 'package:get_storage/get_storage.dart';

class Local {
  static final box = GetStorage();

  Future isMuted(bool isMuted) async {
    return await box.write('isMuted', isMuted);
  }

  bool get ifisMuted => box.read('isMuted') ?? false;

  Future get clean => box.erase();
}
