/// True when a backend response body means success.
///
/// Most endpoints answer `{"status": "success", "code": 2xx, ...}`; a few older
/// ones use `{"success": true, ...}`. Accept both so a created/updated record
/// is never reported to the user as a failure.
bool isApiSuccess(Map<String, dynamic>? body) {
  if (body == null) return false;
  if (body['success'] == true) return true;
  if (body['status'] == 'success') return true;
  final code = body['code'];
  return code is int && code >= 200 && code < 300 && body['status'] != 'error';
}
