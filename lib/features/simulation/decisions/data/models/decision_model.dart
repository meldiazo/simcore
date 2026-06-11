import 'dart:convert';

import 'package:simcore_frontend/features/simulation/decisions/entities/decision.dart';

class DecisionModel extends Decision {
  DecisionModel({
    required super.id,
    required super.companyId,
    required super.module,
    required super.decisionType,
    required super.payload,
    required super.justification,
    super.createdAt,
  });

  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    return DecisionModel(
      id: json['id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      decisionType: json['decisionType']?.toString() ?? '',
      payload: _payloadToMap(json['payload']),
      justification: json['justification']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': _tryInt(companyId) ?? companyId,
      'module': module,
      'decisionType': decisionType,

      // El backend espera String, no Map.
      'payload': jsonEncode(payload),

      'justification': justification,
    };
  }

  static Map<String, dynamic> _payloadToMap(dynamic rawPayload) {
    if (rawPayload == null) return <String, dynamic>{};

    if (rawPayload is Map<String, dynamic>) {
      return rawPayload;
    }

    if (rawPayload is Map) {
      return Map<String, dynamic>.from(rawPayload);
    }

    if (rawPayload is String) {
      final text = rawPayload.trim();

      if (text.isEmpty) return <String, dynamic>{};

      try {
        final decoded = jsonDecode(text);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }

        return <String, dynamic>{
          'value': decoded,
        };
      } catch (_) {
        return <String, dynamic>{
          'raw': rawPayload,
        };
      }
    }

    return <String, dynamic>{
      'value': rawPayload.toString(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static int? _tryInt(String value) {
    return int.tryParse(value);
  }
}