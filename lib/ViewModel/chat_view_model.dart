import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/random_id.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:flutter/material.dart';

class ChatViewModel {
  FirestoreService _firestoreService = FirestoreService();
  String _senderId;
  String _peerId;
  String _peerAvatar;
  RandomId randomId = new RandomId();
  List<QueryDocumentSnapshot> _listMessages = new List.from([]);
  TextEditingController textEditingController = TextEditingController();

  ChatViewModel(this._senderId);

  updateChattingWith() async {
    await _firestoreService.updateUserFieldIntoDB(
        _senderId, 'chattingWith', _peerId);
  }

  void sendMessageToUser() async {
    await _firestoreService
        .addMessageToUserIntoDB(computeGroupChatId(), _senderId, _peerId,
            textEditingController.text)
        .then((_) => textEditingController.clear());
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && _listMessages[index - 1].get('idFrom') == _senderId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && _listMessages[index - 1].get('idFrom') != _senderId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  void resetChat() async {
    await _firestoreService.updateUserFieldIntoDB(
        _senderId, 'chattingWith', null);
  }

  Stream<QuerySnapshot> loadMessages() {
    try {
      var snapshots = _firestoreService.getMessagesFromDB(computeGroupChatId());
      _listMessages.clear();
      snapshots.forEach((element) {
        _listMessages.addAll(element.docs);
      });
      return snapshots;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List> loadActiveChats() async {
    try {
      return await _firestoreService.getChatsFromDB(
          senderId, _firestoreService.activeChatCollection);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List> loadPendingChats() async {
    try {
      return await _firestoreService.getChatsFromDB(
          senderId, _firestoreService.pendingChatCollection);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List> loadExpertChats() async {
    try {
      return await _firestoreService.getChatsFromDB(
          senderId, _firestoreService.expertChatCollection);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> addNewRandomChat() async {
    var randomUser = await _firestoreService.getRandomUserFromDB(
        senderId, randomId.generate());
    if (randomUser == null) return false;
    peerId = randomUser['uid'];
    _firestoreService.addChatIntoDB(senderId, peerId);
    return true;
  }

  Future<void> acceptPendingChat() async {
    await _firestoreService.upgradePendingToActiveChatIntoDB(senderId, peerId);
  }

  Future<void> denyPendingChat() async {
    await _firestoreService.removePendingChatFromDB(senderId, peerId);
    await _firestoreService.removeMessagesFromDB(computeGroupChatId());
  }

  Future<void> deleteChat() async {
    await _firestoreService.removeActiveChatFromDB(senderId, peerId);
  }

  String computeGroupChatId() {
    if (_senderId.hashCode <= _peerId.hashCode) {
      return '$_senderId-$_peerId';
    } else {
      return '$_peerId-$_senderId';
    }
  }

  set peerId(String peerId) {
    this._peerId = peerId;
  }

  set peerAvatar(String peerAvatar) {
    this._peerAvatar = peerAvatar;
  }

  get senderId => _senderId;

  get peerId => _peerId;

  get peerAvatar => _peerAvatar;

  TextEditingController get textController => textEditingController;
}
