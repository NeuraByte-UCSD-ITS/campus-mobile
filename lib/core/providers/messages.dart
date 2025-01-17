import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/messages.dart';
import 'package:flutter/material.dart';
import '../../ui/navigator/bottom.dart';

//MESSAGES API UNIX TIMESTAMPS IN MILLISECONDS NOT SECONDS

ScrollController notificationScrollController = ScrollController();

class MessagesDataProvider extends ChangeNotifier {
  MessagesDataProvider() {
    /// DEFAULT STATES
    notificationScrollController.addListener(() {
      var triggerFetchMoreSize =
          0.9 * notificationScrollController.position.maxScrollExtent;

      if (notificationScrollController.position.pixels > triggerFetchMoreSize) {
        if (!_isLoading&& _hasMoreMessagesToLoad) {
          fetchMessages(false);
        }
      }
      setNotificationsScrollOffset(notificationScrollController.offset);
    });
  }

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  int _previousTimestamp = 0;
  String _statusText = NotificationsConstants.statusFetching;
  bool _hasMoreMessagesToLoad = false;
  final notificationScrollController = ScrollController();

  /// MODELS
  List<MessageElement> _messages = [];
  UserDataProvider? userDataProvider;

  final MessageService _messageService = MessageService();

  //Fetch messages
  Future<bool> fetchMessages(bool clearMessages) async {
    _isLoading = true; _error = null; var returnVal;
    notifyListeners();
    if (clearMessages) {
      _clearMessages();
    }
    if (userDataProvider != null && userDataProvider!.isLoggedIn) {
      returnVal = await retrieveMoreMyMessages();
    } else {
      returnVal = await retrieveMoreTopicMessages();
    }
    _isLoading = false;
    return returnVal;
  }

  void _clearMessages() {
    _messages = [];
    _hasMoreMessagesToLoad = false;
    _previousTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  Future<bool> retrieveMoreMyMessages() async {
    _isLoading = true; _error = null;
    notifyListeners();

    int returnedTimestamp;
    int timestamp = _previousTimestamp;
    Map<String, String> headers = {
      "accept": "application/json",
      "Authorization":
          "Bearer " + userDataProvider!.authenticationModel.accessToken!,
    };

    if (await _messageService.fetchMyMessagesData(timestamp, headers)) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      updateMessages(temp);
      makeOrderedMessagesList();
      returnedTimestamp = _messageService.messagingModels.next ?? 0;
      // checks if we have no more messages to paginate through
      _hasMoreMessagesToLoad = !(_previousTimestamp == returnedTimestamp || returnedTimestamp == 0);
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> retrieveMoreTopicMessages() async {
    _isLoading = true; _error = null;
    notifyListeners();
    int returnedTimestamp;

    if (await _messageService.fetchTopicData(
        _previousTimestamp, userDataProvider!.subscribedTopics!)) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      updateMessages(temp);
      makeOrderedMessagesList();
      returnedTimestamp = _messageService.messagingModels.next ?? 0;
      // checks if we have no more messages to paginate through
      _hasMoreMessagesToLoad = !(_previousTimestamp == returnedTimestamp || returnedTimestamp == 0);
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = _messageService.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void makeOrderedMessagesList() {
    Map<String, MessageElement> uniqueMessages =
        Map<String, MessageElement>();
    uniqueMessages = Map.fromIterable(_messages,
        key: (message) => message.messageId, value: (message) => message);
    _messages.clear();
    uniqueMessages.forEach((k, v) => _messages.add(v));
    _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void updateMessages(List<MessageElement> newMessages) {
    _messages.addAll(newMessages);
    if (_messages.length == 0) {
      _statusText = NotificationsConstants.statusNoMessages;
    } else {
      _statusText = NotificationsConstants.statusNone;
    }
  }

  /// SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  String get statusText => _statusText;
  bool get hasMoreMessagesToLoad => _hasMoreMessagesToLoad;
  ScrollController get scrollController => notificationScrollController;

  List<MessageElement> get messages => _messages;
}
