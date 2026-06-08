import 'dart:developer';

import 'package:zendesk_sdk/zendesk_sdk.dart';

import 'zendesk_env.dart';

const _logTag = 'zendeskSdkFlutter';

/// Presentation controller: UI talks to [ZendeskService], not the platform layer (MVC).
class ZendeskController {
  ZendeskController({
    required ZendeskService service,
    required ZendeskEnv env,
    this.demoUser = const ZendeskUser(
      name: 'John Doe',
      emailId: 'abc@mail.com',
      userId: 'abc123',
      userType: 'RIDER',
    ),
  })  : _service = service,
        _env = env;

  factory ZendeskController.defaults({ZendeskEnv? env}) {
    final environment = env ?? ZendeskEnv();
    return ZendeskController(
      service: ZendeskSdk.instance.service,
      env: environment,
    );
  }

  final ZendeskService _service;
  final ZendeskEnv _env;
  final ZendeskUser demoUser;

  String? initError;

  Future<void> initialize() async {
    try {
      await _env.load();
      final result = await _service.initializeResult(
        config: ZendeskConfig(
          url: _env.require(ZendeskEnv.keyUrl),
          appId: _env.require(ZendeskEnv.keyAppId),
          clientId: _env.require(ZendeskEnv.keyClientId),
        ),
        user: demoUser,
      );

      initError = switch (result) {
        ZendeskSuccess() => null,
        ZendeskFailure(:final error) => error.message,
      };
    } on ZendeskSdkException catch (error, stackTrace) {
      log(
        name: _logTag,
        'Error initializing the Zendesk SDK',
        error: error,
        stackTrace: stackTrace,
      );
      initError = error.message;
    } catch (error, stackTrace) {
      log(
        name: _logTag,
        'Error loading Zendesk env file',
        error: error,
        stackTrace: stackTrace,
      );
      initError = error.toString();
    }
  }

  Future<void> openHelpCenter() {
    return _service.showHelpCenter(
      CategoryListHelpCenterQuery(user: demoUser, categoryIdList: const []),
    );
  }

  Future<void> openTicketForm() {
    return _service.sendTicket(
      ZendeskTicketRequest(
        user: demoUser.copyWith(name: 'Testing User', userId: 'userId'),
        tripId: 'tripId',
        customFields: const [
          ZendeskCustomField(fieldId: 29516552016157, value: 'RIDER'),
        ],
      ),
    );
  }

  Future<void> openTicketList() {
    return _service.showTicketList(
      user: demoUser.copyWith(name: 'Testing User', userId: 'userId'),
      tripId: 'tripId',
    );
  }

  Future<void> startChat() {
    return _service.startChat(
      channelId: _env.require(ZendeskEnv.keyChannelId),
    );
  }

  Future<int> unreadCount() => _service.getUnreadMessageCount();

  Future<void> logout() => _service.logout();
}
