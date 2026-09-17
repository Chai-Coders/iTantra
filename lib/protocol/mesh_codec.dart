import 'dart:convert';
import 'dart:typed_data';
import '../transceiver_engine.dart';

class MeshCodec {
  static const int magicByte = 0xAA;
  static const int protocolVersion = 3;

  static const Map<String, int> languageCodes = {
    'Malayalam': 0,
    'Hindi': 1,
    'Gujarati': 2,
    'Marathi': 3,
    'Kannada': 4,
    'Tamil': 5,
    'Telugu': 6,
    'Odia': 7,
    'Bengali': 8,
    'English': 9,
    'ALL': 255,
  };

  static final Map<int, String> reverseLanguageCodes = {
    for (var entry in languageCodes.entries) entry.value: entry.key,
  };

  /// Binary Frame Layout (Version 3 with Geo-Coordinates):
  /// [0] Magic: 0xAA
  /// [1] Version: 0x03
  /// [2] Type (0: beacon, 1: voiceText, 2: prioritySos)
  /// [3..10] 64-bit Timestamp
  /// [11] Source Lang Code
  /// [12] Target Lang Code
  /// [13] Hops
  /// [14] TTL
  /// [15..22] Latitude (float64, 8 bytes)
  /// [23..30] Longitude (float64, 8 bytes)
  /// [31] SenderID Length (L1)
  /// [32 .. 31+L1] SenderID ASCII
  /// [32+L1] PacketID Length (L2)
  /// [33+L1 .. 32+L1+L2] PacketID ASCII
  /// [33+L1+L2] SenderName Length (L3)
  /// [34+L1+L2 .. 33+L1+L2+L3] SenderName UTF-8
  /// [34+L1+L2+L3 .. 35+L1+L2+L3] Payload Length (uint16)
  /// [36+L1+L2+L3 .. end] Payload UTF-8
  static Uint8List encode(TransceiverPacket packet) {
    final senderIdBytes = ascii.encode(packet.senderId);
    final packetIdBytes = ascii.encode(packet.packetId);
    final senderNameBytes = utf8.encode(packet.senderName);
    final payloadBytes = utf8.encode(packet.content);

    final totalSize = 36 +
        senderIdBytes.length +
        packetIdBytes.length +
        senderNameBytes.length +
        payloadBytes.length;

    final buffer = Uint8List(totalSize);
    final byteData = ByteData.sublistView(buffer);

    buffer[0] = magicByte;
    buffer[1] = protocolVersion;
    buffer[2] = packet.type.index;
    byteData.setInt64(3, packet.timestamp, Endian.big);
    buffer[11] = languageCodes[packet.sourceLang] ?? 9;
    buffer[12] = languageCodes[packet.targetLang] ?? 255;
    buffer[13] = packet.hops;
    buffer[14] = packet.ttl;

    // Geo-telemetry payload
    byteData.setFloat64(15, packet.latitude, Endian.big);
    byteData.setFloat64(23, packet.longitude, Endian.big);

    int offset = 31;

    // SenderID
    buffer[offset] = senderIdBytes.length;
    offset += 1;
    buffer.setRange(offset, offset + senderIdBytes.length, senderIdBytes);
    offset += senderIdBytes.length;

    // PacketID
    buffer[offset] = packetIdBytes.length;
    offset += 1;
    buffer.setRange(offset, offset + packetIdBytes.length, packetIdBytes);
    offset += packetIdBytes.length;

    // SenderName
    buffer[offset] = senderNameBytes.length;
    offset += 1;
    buffer.setRange(offset, offset + senderNameBytes.length, senderNameBytes);
    offset += senderNameBytes.length;

    // Payload
    byteData.setUint16(offset, payloadBytes.length, Endian.big);
    offset += 2;
    buffer.setRange(offset, offset + payloadBytes.length, payloadBytes);

    return buffer;
  }

  static TransceiverPacket decode(Uint8List data) {
    if (data.isNotEmpty && data[0] == magicByte && data.length >= 36) {
      try {
        final byteData = ByteData.sublistView(data);
        final typeIndex = data[2];
        final packetType = (typeIndex >= 0 && typeIndex < PacketType.values.length)
            ? PacketType.values[typeIndex]
            : PacketType.beacon;

        final timestamp = byteData.getInt64(3, Endian.big);
        final sourceLang = reverseLanguageCodes[data[11]] ?? 'English';
        final targetLang = reverseLanguageCodes[data[12]] ?? 'Malayalam';
        final hops = data[13];
        final ttl = data[14];

        final latitude = byteData.getFloat64(15, Endian.big);
        final longitude = byteData.getFloat64(23, Endian.big);

        int offset = 31;

        final senderIdLen = data[offset];
        offset += 1;
        final senderId = ascii.decode(data.sublist(offset, offset + senderIdLen));
        offset += senderIdLen;

        final packetIdLen = data[offset];
        offset += 1;
        final packetId = ascii.decode(data.sublist(offset, offset + packetIdLen));
        offset += packetIdLen;

        final senderNameLen = data[offset];
        offset += 1;
        final senderName = utf8.decode(data.sublist(offset, offset + senderNameLen));
        offset += senderNameLen;

        final payloadLen = byteData.getUint16(offset, Endian.big);
        offset += 2;
        final content = utf8.decode(data.sublist(offset, offset + payloadLen));

        return TransceiverPacket(
          packetId: packetId,
          type: packetType,
          senderId: senderId,
          senderName: senderName,
          sourceLang: sourceLang,
          targetLang: targetLang,
          content: content,
          timestamp: timestamp,
          hops: hops,
          ttl: ttl,
          latitude: latitude,
          longitude: longitude,
        );
      } catch (_) {}
    }

    // Legacy JSON fallback
    final jsonStr = utf8.decode(data);
    return TransceiverPacket.fromJson(jsonDecode(jsonStr));
  }
}