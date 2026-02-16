import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  
  // Get all published events
  Stream<List<Event>> getPublishedEvents() {
    return _firestore
        .collection('events')
        .where('isPublished', isEqualTo: true)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }
  
  // Get upcoming events
  Stream<List<Event>> getUpcomingEvents() {
    return _firestore
        .collection('events')
        .where('isPublished', isEqualTo: true)
        .where('startTime', isGreaterThan: Timestamp.now())
        .orderBy('startTime', descending: false)
        .limit(AppConfig.eventsPerPage)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }
  
  // Get past events
  Stream<List<Event>> getPastEvents() {
    return _firestore
        .collection('events')
        .where('isPublished', isEqualTo: true)
        .where('endTime', isLessThan: Timestamp.now())
        .orderBy('endTime', descending: true)
        .limit(AppConfig.eventsPerPage)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }
  
  // Get featured events
  Stream<List<Event>> getFeaturedEvents() {
    return _firestore
        .collection('events')
        .where('isPublished', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .orderBy('startTime', descending: false)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }
  
  // Get event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) return null;
      return Event.fromFirestore(doc);
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }
  
  // Create event (Admin/Organizer only)
  Future<String> createEvent(Event event, AppUser creator) async {
    try {
      if (!creator.isOrganizer) {
        throw Exception('Only organizers can create events');
      }
      
      final eventData = event.toFirestore();
      final docRef = await _firestore.collection('events').add(eventData);
      
      // Generate QR code data
      await _firestore.collection('events').doc(docRef.id).update({
        'qrCodeData': _generateQRCodeData(docRef.id),
      });
      
      return docRef.id;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }
  
  // Update event
  Future<void> updateEvent(Event event, AppUser updater) async {
    try {
      if (!updater.isOrganizer) {
        throw Exception('Only organizers can update events');
      }
      
      await _firestore.collection('events').doc(event.id).update(event.toFirestore());
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }
  
  // Delete event
  Future<void> deleteEvent(String eventId, AppUser deleter) async {
    try {
      if (!deleter.isAdmin) {
        throw Exception('Only admins can delete events');
      }
      
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }
  
  // Register for event
  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      final event = await getEventById(eventId);
      if (event == null) throw Exception('Event not found');
      
      // Check if registration is still open
      if (event.hasRegistrationClosed) {
        throw Exception('Registration has closed');
      }
      
      // Check if already registered
      final existingReg = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();
      
      if (existingReg.docs.isNotEmpty) {
        throw Exception('Already registered for this event');
      }
      
      // Check if event is full
      final isWaitlisted = event.isFull;
      
      final registration = EventRegistration(
        id: _uuid.v4(),
        eventId: eventId,
        userId: userId,
        registeredAt: DateTime.now(),
        isWaitlisted: isWaitlisted,
        isApproved: !event.requiresApproval,
      );
      
      // Create registration
      await _firestore.collection('registrations').add(registration.toFirestore());
      
      // Update event registration count
      await _firestore.collection('events').doc(eventId).update({
        isWaitlisted ? 'waitlistCount' : 'currentRegistrations': FieldValue.increment(1),
      });
      
      // Update user's registered events
      await _firestore.collection('users').doc(userId).update({
        'registeredEventIds': FieldValue.arrayUnion([eventId]),
      });
    } catch (e) {
      print('Error registering for event: $e');
      rethrow;
    }
  }
  
  // Cancel registration
  Future<void> cancelRegistration(String eventId, String userId) async {
    try {
      final registration = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();
      
      if (registration.docs.isEmpty) {
        throw Exception('Registration not found');
      }
      
      final regDoc = registration.docs.first;
      final regData = EventRegistration.fromFirestore(regDoc);
      
      await _firestore.collection('registrations').doc(regDoc.id).delete();
      
      // Update event registration count
      await _firestore.collection('events').doc(eventId).update({
        regData.isWaitlisted ? 'waitlistCount' : 'currentRegistrations': FieldValue.increment(-1),
      });
      
      // Update user's registered events
      await _firestore.collection('users').doc(userId).update({
        'registeredEventIds': FieldValue.arrayRemove([eventId]),
      });
    } catch (e) {
      print('Error canceling registration: $e');
      rethrow;
    }
  }
  
  // Mark attendance via QR code
  Future<void> markAttendance(String eventId, String userId, String qrScanId) async {
    try {
      final registration = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();
      
      if (registration.docs.isEmpty) {
        throw Exception('User not registered for this event');
      }
      
      final regDoc = registration.docs.first;
      final regData = EventRegistration.fromFirestore(regDoc);
      
      if (regData.hasAttended) {
        if (!AppConfig.allowDuplicateScans) {
          throw Exception('Attendance already marked');
        }
      }
      
      await _firestore.collection('registrations').doc(regDoc.id).update({
        'hasAttended': true,
        'attendedAt': Timestamp.now(),
        'attendanceMethod': 'qr',
        'qrScanId': qrScanId,
      });
      
      // Update event attendance count
      if (!regData.hasAttended) {
        await _firestore.collection('events').doc(eventId).update({
          'actualAttendance': FieldValue.increment(1),
        });
        
        // Update user's attended events
        await _firestore.collection('users').doc(userId).update({
          'attendedEventIds': FieldValue.arrayUnion([eventId]),
          'engagementScore': FieldValue.increment(10),
        });
      }
    } catch (e) {
      print('Error marking attendance: $e');
      rethrow;
    }
  }
  
  // Manual attendance marking (organizer)
  Future<void> markAttendanceManual(String eventId, String userId, AppUser organizer) async {
    try {
      if (!organizer.isOrganizer) {
        throw Exception('Only organizers can manually mark attendance');
      }
      
      final registration = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();
      
      if (registration.docs.isEmpty) {
        throw Exception('User not registered for this event');
      }
      
      final regDoc = registration.docs.first;
      final regData = EventRegistration.fromFirestore(regDoc);
      
      await _firestore.collection('registrations').doc(regDoc.id).update({
        'hasAttended': true,
        'attendedAt': Timestamp.now(),
        'attendanceMethod': 'manual',
      });
      
      if (!regData.hasAttended) {
        await _firestore.collection('events').doc(eventId).update({
          'actualAttendance': FieldValue.increment(1),
        });
        
        await _firestore.collection('users').doc(userId).update({
          'attendedEventIds': FieldValue.arrayUnion([eventId]),
          'engagementScore': FieldValue.increment(10),
        });
      }
    } catch (e) {
      print('Error marking manual attendance: $e');
      rethrow;
    }
  }
  
  // Get user's registered events
  Stream<List<Event>> getUserRegisteredEvents(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      final user = AppUser.fromFirestore(userDoc);
      if (user.registeredEventIds.isEmpty) return <Event>[];
      
      final events = await Future.wait(
        user.registeredEventIds.map((id) => getEventById(id))
      );
      
      return events.whereType<Event>().toList();
    });
  }
  
  // Get event registrations (for organizers)
  Future<List<EventRegistration>> getEventRegistrations(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();
      
      return snapshot.docs.map((doc) => EventRegistration.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting event registrations: $e');
      return [];
    }
  }
  
  // Generate QR code data
  String _generateQRCodeData(String eventId) {
    return 'event:$eventId:${_uuid.v4()}';
  }
  
  // Verify QR code
  Future<Map<String, dynamic>> verifyQRCode(String qrData) async {
    try {
      final parts = qrData.split(':');
      if (parts.length != 3 || parts[0] != 'event') {
        throw Exception('Invalid QR code');
      }
      
      final eventId = parts[1];
      final scanId = parts[2];
      
      final event = await getEventById(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }
      
      return {
        'valid': true,
        'eventId': eventId,
        'scanId': scanId,
        'event': event,
      };
    } catch (e) {
      return {
        'valid': false,
        'error': e.toString(),
      };
    }
  }
}
