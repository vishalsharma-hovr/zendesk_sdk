import 'dart:io';

import 'package:flutter/services.dart';

/// Loads Zendesk credentials from native config (AndroidManifest / Info.plist),
/// with a `.secrets/zendesk.env` file fallback for local development.
class ZendeskEnv {
  ZendeskEnv({String? filePath}) : filePath = filePath;

  static const String secretsDir = '.secrets';
  static const String fileName = 'zendesk.env';
  static const String configChannelName = 'zendesk_config';
  static const String configMethodGetConfig = 'getZendeskConfig';

  static const String keyUrl = 'ZENDESK_URL';
  static const String keyAppId = 'ZENDESK_APP_ID';
  static const String keyClientId = 'ZENDESK_CLIENT_ID';
  static const String keyChannelId = 'ZENDESK_CHANNEL_ID';

  static const MethodChannel _configChannel = MethodChannel(configChannelName);

  static const List<String> _secretsPathCandidates = [
    '$secretsDir/$fileName',
    '../$secretsDir/$fileName',
    '../../$secretsDir/$fileName',
  ];

  final String? filePath;
  final Map<String, String> _values = {};

  Future<void> load() async {
    _values.clear();

    final nativeConfig = await _loadFromNativeWithRetry();
    if (_hasRequiredValues(nativeConfig)) {
      _values.addAll(nativeConfig);
      return;
    }

    final fileConfig = await _loadFromSecretsFile();
    if (_hasRequiredValues(fileConfig)) {
      _values.addAll(fileConfig);
      return;
    }

    final nativeSummary = _summarizeConfig(nativeConfig);
    throw StateError(
      'Zendesk config is missing on device. '
      'Create .secrets/zendesk.env, run '
      'example/ios/scripts/generate_secrets_xcconfig.sh, then '
      'flutter clean && flutter run. '
      'Native config: $nativeSummary',
    );
  }

  String require(String key) {
    final value = _values[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required config key: $key');
    }
    return value;
  }

  Future<Map<String, String>> _loadFromNativeWithRetry() async {
    const maxAttempts = 5;
    const delay = Duration(milliseconds: 200);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final config = await _loadFromNative();
      if (_hasRequiredValues(config)) {
        return config;
      }

      if (attempt < maxAttempts - 1) {
        await Future<void>.delayed(delay);
      }
    }

    return _loadFromNative();
  }

  Future<Map<String, String>> _loadFromNative() async {
    try {
      final result = await _configChannel.invokeMapMethod<String, dynamic>(
        configMethodGetConfig,
      );
      if (result == null) {
        return {};
      }

      return result.map(
        (key, value) => MapEntry(key, _normalizeValue(value?.toString() ?? '')),
      );
    } on MissingPluginException {
      return {};
    }
  }

  Future<Map<String, String>> _loadFromSecretsFile() async {
    final paths = <String>[
      if (filePath != null) filePath!,
      ..._secretsPathCandidates,
    ];

    for (final path in paths) {
      final file = File(path);
      if (!await file.exists()) {
        continue;
      }

      final values = <String, String>{};
      final lines = await file.readAsLines();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) {
          continue;
        }

        final separatorIndex = trimmed.indexOf('=');
        if (separatorIndex <= 0) {
          continue;
        }

        final key = trimmed.substring(0, separatorIndex).trim();
        final value = trimmed.substring(separatorIndex + 1).trim();
        values[key] = _stripQuotes(value);
      }

      if (values.isNotEmpty) {
        return values;
      }
    }

    return {};
  }

  bool _hasRequiredValues(Map<String, String> values) {
    return _isValidValue(values[keyUrl]) &&
        _isValidValue(values[keyAppId]) &&
        _isValidValue(values[keyClientId]);
  }

  bool _isValidValue(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    if (value.startsWith(r'$(')) {
      return false;
    }

    // xcconfig treats // as a comment; a truncated URL ends up as "https:" only.
    if (value == 'https:' || value == 'http:') {
      return false;
    }

    return true;
  }

  String _normalizeValue(String value) {
    final trimmed = _stripQuotes(value.trim());
    if (trimmed.startsWith(r'$(') || trimmed == 'https:' || trimmed == 'http:') {
      return '';
    }
    return trimmed;
  }

  String _summarizeConfig(Map<String, String> values) {
    String status(String key) {
      final value = values[key];
      if (value == null || value.isEmpty) return '$key=missing';
      if (value.startsWith(r'$(')) return '$key=unresolved';
      if (value == 'https:' || value == 'http:') return '$key=truncated';
      return '$key=set';
    }

    return [
      status(keyUrl),
      status(keyAppId),
      status(keyClientId),
      status(keyChannelId),
    ].join(', ');
  }

  String _stripQuotes(String value) {
    if (value.length >= 2) {
      final startsWithQuote = value.startsWith('"') || value.startsWith("'");
      final endsWithQuote = value.endsWith('"') || value.endsWith("'");
      if (startsWithQuote && endsWithQuote) {
        return value.substring(1, value.length - 1);
      }
    }
    return value;
  }
}
