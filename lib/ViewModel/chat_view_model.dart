import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/random_id.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/user_chat.dart';
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

  ChatViewModel(String senderId) {
    this._senderId = senderId;
  }

  updateChattingWith() async {
    await _firestoreService.updateUserFieldIntoDB(_senderId, 'chattingWith', _peerId);
  }

  void sendMessage() async {
    if (textEditingController.text.trim() != '') {
      await _firestoreService.addMessageIntoDB(computeGroupChatId(), _senderId, _peerId, textEditingController.text)
          .then((_) => textEditingController.clear());
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && _listMessages[index - 1].get('idFrom') == _senderId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

    bool isLastMessageRight(int index) {
    if ((index > 0 && _listMessages[index - 1].get('idFrom') != _senderId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  void resetChat() async {
    await _firestoreService.updateUserFieldIntoDB(_senderId, 'chattingWith', null);
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

  Future<List<UserChat>> loadUsers() async {
    List<UserChat> userChats = new List.from([]);
    try {
      var snap = await _firestoreService.getActiveChatUsers(senderId);
      for(var doc in snap.docs) {
        userChats.add(new UserChat.fromDocument(doc));
      }
      return userChats;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> addNewRandomChat() async {
    String randomUserId;
    var activeIds = await _firestoreService.getActiveChatIds(senderId);
    do {
      randomUserId = await _firestoreService.getRandomUserFromDB(senderId, randomId.generate());
      if(randomUserId == null)
        return false;
    } while(randomUserId == senderId || activeIds.contains(randomUserId));
    peerId = randomUserId;
    await _firestoreService.addChatIntoDB(senderId, peerId);
    return true;
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

  get senderId => this._senderId;

  get peerId => this._peerId;

  get peerAvatar => this._peerAvatar;
}
