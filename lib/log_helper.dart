import 'package:logger/logger.dart';

final logger = LogHelper().logger;

class LogHelper {
  static final LogHelper _instance = LogHelper._internal();
  final Logger logger = Logger();

  factory LogHelper() {
    return _instance;
  }

  // シングルトンにするため、コンストラクタをprivateにする
  LogHelper._internal();

  static Logger get instance => _instance.logger;
}
