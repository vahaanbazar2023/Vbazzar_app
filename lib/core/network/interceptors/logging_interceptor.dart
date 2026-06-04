import 'package:dio/dio.dart';
import '../../services/logger_service.dart';

class LoggingInterceptor extends Interceptor {
  final _log = LoggerService.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isMultipart = options.data is FormData;
    final buffer = StringBuffer()
      ..writeln('→ ${options.method} ${options.uri}')
      ..writeln('   Headers: ${options.headers}');
    if (isMultipart) {
      final formData = options.data as FormData;
      buffer.writeln('   [Multipart Form Data]');
      buffer.writeln('   Fields: ${formData.fields.map((e) => '${e.key}=${e.value}').toList()}');
      buffer.writeln('   Files: ${formData.files.map((f) => '${f.key}=>${f.value.filename} (${f.value.length} bytes)').toList()}');
    } else {
      buffer.writeln('   Data: ${options.data}');
    }
    _log.info(buffer.toString());
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
    final buffer = StringBuffer()
      ..writeln('✕ ${err.requestOptions.method} ${err.requestOptions.uri}')
      ..writeln('   Status: ${err.response?.statusCode}')
      ..writeln('   Message: ${err.message}')
      ..writeln('   Response Data: ${err.response?.data}');
    _log.error(buffer.toString());
    handler.next(err);
  }
}
