import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// Model payload status JSON:
/// {"status":"1","tipe":"5","site":"cimacan","addr":"1","value":"200"}
class StatusData {
  final String status;
  final String tipe;
  final String site;
  final String addr;
  final String value;

  StatusData({
    required this.status,
    required this.tipe,
    required this.site,
    required this.addr,
    required this.value,
  });

  factory StatusData.fromJson(Map<String, dynamic> json) {
    // paksa ke string agar aman meski server kirim int/bool
    String s(dynamic v) => v?.toString() ?? '';
    return StatusData(
      status: s(json['status']),
      tipe:   s(json['tipe']),
      site:   s(json['site']),
      addr:   s(json['addr']),
      value:  s(json['value']),
    );
  }
}

class MqttService with ChangeNotifier {
  /// Client dibuat nullable agar aman dari LateInitializationError.
  MqttServerClient? _client;

  /// Koneksi global ke broker (bukan per-addr).
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Simpan last payload per addr.
  final Map<String, StatusData> _messagesByAddr = {};
  StatusData? getMessageByAddr(String addr) => _messagesByAddr[addr];

  /// Heartbeat per addr → dipakai UI untuk badge ONLINE/OFFLINE.
  final Map<String, DateTime> _lastSeen = {};

  /// Antrian topik kalau subscribe dipanggil sebelum connect.
  final Set<String> _pendingTopics = {};

  /// Timer ringan untuk memicu repaint status OFFLINE (tiap 5s).
  Timer? _offlineChecker;

  /// ======== CONNECT (dipanggil dari HomePage) ========
  ///
  /// Pindahkan setting broker ke HomePage (dinamis), lalu panggil:
  /// mqtt.connect(broker: 'x.x.x.x', port: 1883, clientId: 'flutter_123')
  Future<void> connect({
    required String broker,
    required int port,
    required String clientId,
    int keepAliveSec = 20,
    bool logging = false,
  }) async {
    // inisialisasi client
    _client = MqttServerClient(broker, clientId)
      ..port = port
      ..keepAlivePeriod = keepAliveSec
      ..logging(on: logging);

    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .keepAliveFor(keepAliveSec);
    _client!.connectionMessage = connMsg;

    try {
      await _client!.connect();
    } catch (e) {
      debugPrint('❌ MQTT connect error: $e');
      _client?.disconnect();
      _isConnected = false;
      notifyListeners();
      return;
    }

    // listen pesan masuk
    _client!.updates?.listen(_onMessage);

    // timer untuk memicu update UI status OFFLINE (5 detik)
    _offlineChecker?.cancel();
    _offlineChecker = Timer.periodic(const Duration(seconds: 5), (_) {
      // Tidak ubah state, hanya memaksa UI re-check isClientOnline(addr)
      notifyListeners();
    });
  }

  /// ======== SUBSCRIBE ========
  ///
  /// Aman dipanggil kapan pun. Kalau belum connect, topik di-antri
  /// dan akan otomatis di-subscribe saat onConnected().
  void subscribeTopic(String topic) {
    if (_client == null || !_isConnected) {
      _pendingTopics.add(topic);
      debugPrint('⏳ Queue subscribe: $topic');
      return;
    }
    _client!.subscribe(topic, MqttQos.atLeastOnce);
    debugPrint('🔔 Subscribed: $topic');
  }

  /// ======== PUBLISH ========
  void publishMessage(String topic, String message) {
    if (_client == null || !_isConnected) {
      debugPrint('⚠️ Cannot publish (not connected) to $topic');
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    debugPrint('📤 Published [$topic]: $message');
  }

  /// ======== ONLINE STATE PER-ADDR ========
  ///
  /// Anggap ONLINE kalau ada pesan ≤5 detik terakhir untuk addr tsb.
  bool isClientOnline(String addr) {
    final ts = _lastSeen[addr];
    if (ts == null) return false;
    return DateTime.now().difference(ts).inSeconds <= 5;
  }

  /// ======== DISCONNECT ========
  void disconnect() {
    _offlineChecker?.cancel();
    _client?.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  /// ======== CALLBACKS ========
  void _onConnected() {
    _isConnected = true;

    // flush semua subscribe yang di-antri sebelum konek
    for (final t in _pendingTopics) {
      _client?.subscribe(t, MqttQos.atLeastOnce);
      debugPrint('✅ Subscribed (flush): $t');
    }
    _pendingTopics.clear();

    notifyListeners();
    debugPrint('✅ MQTT connected');
  }

  void _onDisconnected() {
    _isConnected = false;
    notifyListeners();
    debugPrint('🔌 MQTT disconnected');
  }

  /// Handler pesan masuk dari broker.
  void _onMessage(List<MqttReceivedMessage<MqttMessage?>>? events) {
    if (events == null || events.isEmpty) return;

    final msg = events.first.payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
    final topic = events.first.topic;

    // Coba ambil addr dari topic: MQTTsample/{site}/{addr}/...
    String? _addrFromTopic() {
      final parts = topic.split('/');
      // Minimal: ["MQTTsample", "{site}", "{addr}", ...]
      return parts.length >= 3 ? parts[2] : null;
    }

    // 1) coba parse sebagai JSON StatusData
    bool handled = false;
    try {
      final map = json.decode(payload) as Map<String, dynamic>;
      final data = StatusData.fromJson(map);
      if (data.addr.isNotEmpty) {
        _messagesByAddr[data.addr] = data;
        _lastSeen[data.addr] = DateTime.now();
        handled = true;
      }
    } catch (_) {
      // bukan JSON status? lanjut ke fallback
    }

    // 2) fallback: kalau payload bukan JSON status tetapi
    //    topic memuat addr (mis. .../value), tandai lastSeen addr tsb.
    if (!handled) {
      final addr = _addrFromTopic();
      if (addr != null) {
        _lastSeen[addr] = DateTime.now();
      }
    }

    notifyListeners();
    debugPrint('📩 [$topic] $payload');
  }
}
