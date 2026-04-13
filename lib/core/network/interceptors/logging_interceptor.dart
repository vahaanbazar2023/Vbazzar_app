import 'package:dio/dio.dart';
import '../../services/logger_service.dart';

class LoggingInterceptor extends Interceptor {
  final _log = LoggerService.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.info(
      '→ ${options.method} ${options.uri}\n'
      '   Headers: ${options.headers}\n'
      '   Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.info(
      '← ${response.statusCode} ${response.requestOptions.uri}\n'
      '   Data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.error(
      '✕ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      '   ${err.message}',
    );
    handler.next(err);
  }
}
