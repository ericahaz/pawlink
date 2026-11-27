import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _webVapidKey =
      'BHkdPvczrlZtKIcRBV7eshkTwpHUuTnOSlcpFba0Z_m9i-lKwb3eUux0MmBlh8GXLoztMhSN2T6fqvz_A9JZZ84';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<String>? _tokenRefreshSubscription;

  String? _activeUid;
  String? _currentToken;

  // ---------------------------------------------------------------------------
  // IN-APP FIRESTORE NOTIFICATIONS
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  /// Streams all notifications belonging to the signed-in user.
  /// Newest notifications appear first.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getMyNotificationsStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(
        <QueryDocumentSnapshot<Map<String, dynamic>>>[],
      );
    }

    return _notifications
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.toList();

      docs.sort((a, b) {
        final aTime = a.data()['createdAt'];
        final bTime = b.data()['createdAt'];

        final aDate = aTime is Timestamp ? aTime.toDate() : DateTime(0);
        final bDate = bTime is Timestamp ? bTime.toDate() : DateTime(0);

        return bDate.compareTo(aDate);
      });

      return docs;
    });
  }

  /// Streams the current user's unread notification count.
  Stream<int> getUnreadCountStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(0);
    }

    return _notifications
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) => doc.data()['isRead'] != true).length;
    });
  }

  /// Marks one notification as read.
  Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'You must be signed in to update notifications.',
      );
    }

    final ref = _notifications.doc(notificationId);
    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.data()?['userId'] != user.uid) {
      throw StateError(
        'This notification is not available to your account.',
      );
    }

    if (snapshot.data()?['isRead'] == true) {
      return;
    }

    await ref.update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marks all unread notifications belonging to the current user as read.
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'You must be signed in to update notifications.',
      );
    }

    final snapshot =
        await _notifications.where('userId', isEqualTo: user.uid).get();

    final unreadDocs =
        snapshot.docs.where((doc) => doc.data()['isRead'] != true).toList();

    if (unreadDocs.isEmpty) {
      return;
    }

    // Firestore batches support up to 500 writes.
    // Use 450 per batch to stay below the limit.
    for (var start = 0; start < unreadDocs.length; start += 450) {
      final batch = _firestore.batch();

      final end =
          (start + 450 < unreadDocs.length) ? start + 450 : unreadDocs.length;

      for (final doc in unreadDocs.sublist(start, end)) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    }
  }

  // ---------------------------------------------------------------------------
  // FIREBASE CLOUD MESSAGING
  // ---------------------------------------------------------------------------

  /// Requests notification permission and registers the signed-in device.
  Future<void> initializeForUser(String uid) async {
    if (uid.trim().isEmpty) {
      debugPrint('Notification setup skipped: empty user ID.');
      return;
    }

    if (_activeUid == uid && _tokenRefreshSubscription != null) {
      return;
    }

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;

    _activeUid = uid;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        'Notification permission: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Notification permission was denied.');
        return;
      }

      final String? token;

      if (kIsWeb) {
        token = await _messaging.getToken(
          vapidKey: _webVapidKey,
        );
      } else {
        token = await _messaging.getToken();
      }

      if (token == null || token.isEmpty) {
        debugPrint('Firebase did not return an FCM token.');
        return;
      }

      await _saveToken(uid, token);
      _currentToken = token;

      // Listen for FCM token changes.
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
        (newToken) async {
          try {
            final previousToken = _currentToken;

            await _saveToken(uid, newToken);
            _currentToken = newToken;

            if (previousToken != null && previousToken != newToken) {
              await _deleteToken(uid, previousToken);
            }

            debugPrint('FCM token refreshed successfully.');
          } catch (error) {
            debugPrint('FCM token refresh error: $error');
          }
        },
        onError: (error) {
          debugPrint('FCM token refresh listener error: $error');
        },
      );

      debugPrint('FCM device registration completed.');
    } catch (error, stackTrace) {
      debugPrint('Notification initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Saves the FCM token in the user's Firestore account.
  Future<void> _saveToken(String uid, String token) async {
    final tokenRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token);

    final existingToken = await tokenRef.get();

    final tokenData = <String, dynamic>{
      'token': token,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existingToken.exists) {
      tokenData['createdAt'] = FieldValue.serverTimestamp();
    }

    await tokenRef.set(
      tokenData,
      SetOptions(merge: true),
    );
  }

  /// Removes an old FCM token after it has been refreshed.
  Future<void> _deleteToken(String uid, String token) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .delete();
  }

  /// Messages received while the app is open.
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// Messages received when the user taps a notification.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Gets the notification that launched the app.
  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  /// Stops listening for token refresh events.
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription = null;
    _activeUid = null;
    _currentToken = null;
  }
}
