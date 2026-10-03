import 'dart:convert';

/// Local OpenMetadata 1.5.15 quickstart defaults (never for production).
///
/// UI login uses the email + plaintext password. The `/api/v1/users/login`
/// endpoint requires the same email and a **Base64-encoded** password.
const String kOmDefaultBaseUrl = 'http://localhost:8585';
const String kOmDefaultEmail = 'admin@open-metadata.org';
const String kOmDefaultPassword = 'admin';

/// Encode a plaintext password for OM's login API (`LoginRequest.password`).
String encodeOmLoginPassword(String plaintextPassword) =>
    base64Encode(utf8.encode(plaintextPassword));

/// Build a PUT `/api/v1/lineage` body. [fromId] / [toId] must be entity UUIDs
/// (FQNs are rejected by OM 1.5.x `EntityReference.id`).
Map<String, dynamic> buildOmLineagePutBody({
  required String fromId,
  required String toId,
  String? description,
}) {
  final details = <String, dynamic>{
    'source': 'Manual',
  };
  final trimmed = description?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    details['description'] = trimmed;
  }
  return <String, dynamic>{
    'edge': <String, dynamic>{
      'fromEntity': <String, dynamic>{
        'id': fromId,
        'type': 'table',
      },
      'toEntity': <String, dynamic>{
        'id': toId,
        'type': 'table',
      },
      'lineageDetails': details,
    },
  };
}
