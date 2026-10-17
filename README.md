# iTantra -Indian Multilingual TTS & STT Aided Neural Transceiver Radio Access for low bitrate links

> **Smart India Hackathon 2026 · Problem Statement PS26173**
>
> *Offline, real-time, multilingual voice communication and translation for disaster-relief field personnel — zero internet dependency.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![SIH](https://img.shields.io/badge/SIH-PS26173-orange)](https://www.sih.gov.in)

---

## Problem Statement — PS26173

Disaster-response coordination in India is critically hampered by the **language barrier** among multi-state relief teams and affected civilians. During floods, landslides, and other emergencies:

- Network infrastructure is the first thing to collapse.
- Field teams speak different regional languages (Malayalam, Hindi, Bengali, Tamil, etc.).
- Standard translation apps require internet connectivity.
- Delay in relaying critical information costs lives.

**PS26173** demands a device-to-device, fully-offline multilingual communication system that can run on commodity Android hardware over a local hotspot or Wi-Fi — no SIM, no internet, no cloud.

**Demo & Explanation Video:** [https://www.youtube.com/watch?v=S2vu6kKMsqM](https://www.youtube.com/watch?v=S2vu6kKMsqM)

**AI STT Browser Demo:** [https://huggingface.co/spaces/zxnjxd/itantra-stt-browser](https://huggingface.co/spaces/zxnjxd/itantra-stt-browser)

---

## Solution — iTantra

iTantra ("I-Transmitter") is a **Flutter mobile application** that turns every smartphone into a **mesh transceiver node**. Spoken words are:

1. Recognised on-device via the platform STT engine (no cloud API).
2. Translated through an **Edge ML engine** using an English pivot, entirely offline.
3. Broadcast over a **UDP mesh network** (port 8888) to all nodes on the same subnet.
4. Received, re-translated into the listener's native language, and spoken aloud via TTS.

A single spoken sentence in Malayalam reaches a Bengali-speaking rescuer 3 hops away, fully translated, in under 100 ms.

---

## Key Features

### Multilingual Support (10 Indian Languages)

| Language   | Native Script | STT Locale | TTS Locale |
|------------|---------------|------------|------------|
| Malayalam  | മലയാളം        | `ml_IN`    | `ml-IN`    |
| Hindi      | हिन्दी          | `hi_IN`    | `hi-IN`    |
| Tamil      | தமிழ்          | `ta_IN`    | `ta-IN`    |
| Telugu     | తెలుగు         | `te_IN`    | `te-IN`    |
| Kannada    | ಕನ್ನಡ          | `kn_IN`    | `kn-IN`    |
| Bengali    | বাংলা           | `bn_IN`    | `bn-IN`    |
| Marathi    | मराठी           | `mr_IN`    | `mr-IN`    |
| Gujarati   | ગુજરાતી         | `gu_IN`    | `gu-IN`    |
| Odia       | ଓଡ଼ିଆ          | `or_IN`    | `or-IN`    |
| English    | English       | `en_IN`    | `en-IN`    |

### Offline P2P Mesh Networking

- UDP subnet broadcast on **port 8888** — works over any shared Wi-Fi or mobile hotspot.
- **TTL-controlled multi-hop relay**: each node forwards packets to extend range beyond direct radio coverage (default TTL = 4 hops).
- **Beacon heartbeat** every 2 s for peer discovery; stale peers are pruned after 8 s.
- Automatic subnet detection — resolves all live network interface broadcast addresses.
- **Binary MeshCodec v3** encodes every packet into a compact binary frame (vs. JSON fallback), embedding packet type, language codes, geo-coordinates, sender metadata and payload in a deterministic layout.

### Edge ML Translation Engine

- **English Pivot model** — every language translates *to* English first, then *from* English to the target. This eliminates the N² translation problem with only N bidirectional models.
- Pre-built **high-confidence sentence matrix** with 8 disaster-critical compound phrases pre-translated into all 10 languages (evacuation, SOS, medical, supply requests, flood alert, infrastructure damage, status reports, safety confirmation).
- **Multilingual token lexicon** mapping ~150 Indic script tokens per language to English semantic lemmas for free-form speech recognition results.
- Language normalisation resolves script variants, locale codes, and natural-language names to canonical keys.
- Inference latency: **25–40 ms** (simulated; actual on-device lexicon lookup is sub-millisecond).

### Speech Engine (STT + TTS)

- **SttService**: continuous dictation loop using `speech_to_text` package; auto-restarts on silence timeout — no user intervention required.
- Supports all 10 locale-specific STT models.
- **SpeechEngine (TTS)**: `flutter_tts` with per-language locale, pitch, rate, and volume tuning.
- Separate `playVoiceNote` (normal voice) and `playEmergencyAlert` (slower, louder) modes.
- Pre-built phrase book for the two most critical field messages (evacuation, check-in confirmation).

#### Interactive AI STT Browser Demo

For an interactive browser-based demonstration of the AI speech-to-text workflow, see the **AI STT Browser Demo**: [https://huggingface.co/spaces/zxnjxd/itantra-stt-browser](https://huggingface.co/spaces/zxnjxd/itantra-stt-browser).

### Priority SOS Broadcast

- One-tap **BROADCAST PRIORITY SOS** from the home screen.
- SOS packets carry TTL = 6 (2 extra hops vs. normal voice) to maximise propagation.
- On every receiving node the SOS screen interrupts the current view, plays a loud audio alert in the receiver's language, and displays:
  - The translated alert text.
  - Sender name and hop count.
  - Geodesic **bearing** and **distance** to the incident origin.
  - Animated **tactical radar sweep** pointing to the source.

### Geo Engine

- **Haversine formula** for geodesic distance calculation between GPS coordinates (metre-accurate).
- **Azimuth bearing** (0°–360°) from any reference point to any target.
- Each mesh packet carries the sender's latitude/longitude, enabling range-and-bearing computation on receipt without GPS hardware on the receiving device.

### Tactical Radar Display

- Custom `CustomPainter`-based animated radar on the SOS screen.
- Three concentric range rings, cardinal axis lines, and a green sweep gradient.
- A blip positioned at the true geodesic bearing to the incident source.
- Live readout: `BEARING 045° · 320 m`.

### Simulation / Demo Mode

- Toggle from Settings to inject three simulated peers (Kottayam Base, Relay Post B, Sector Edge) across Malayalam, Tamil, and Bengali languages.
- Simulated peers refresh every 3 s and survive the stale-peer pruner — ideal for hackathon demonstrations without needing multiple physical devices.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter UI Layer                   │
│  LocalizationScreen → MeshHomeScreen                │
│  TransmittingScreen  PeersScreen  SettingsScreen    │
│                      SosEmergencyScreen             │
└──────────────────────────┬──────────────────────────┘
                           │
         ┌─────────────────┼────────────────────┐
         ▼                 ▼                    ▼
   SttService         EdgeMlEngine          SpeechEngine
   (STT loop)    (English Pivot translation)  (TTS output)
         │                 │
         └────────┬────────┘
                  ▼
          TransceiverEngine
       (UDP mesh / relay / peers)
                  │
                  ▼
            MeshCodec v3
       (binary packet encoding)
                  │
                  ▼
            GeoEngine
    (Haversine distance & bearing)
```

---

## Tech Stack

| Layer          | Technology                               |
|----------------|------------------------------------------|
| Framework      | Flutter 3.x (Dart 3.2+)                  |
| Networking     | `dart:io` RawDatagramSocket (UDP)        |
| STT            | `speech_to_text ^7.0.0`                  |
| TTS            | `flutter_tts ^4.2.5`                     |
| Permissions    | `permission_handler 11.3.1`              |
| Protocol       | Custom binary codec (MeshCodec v3)       |
| Translation    | On-device lexicon (no API/cloud)         |
| Platforms      | Android, iOS, Windows, Linux, macOS, Web |

---

## Setup & Installation

### Prerequisites

- Flutter SDK ≥ 3.2.0 (stable channel recommended)
- Dart SDK ≥ 3.2.0 (bundled with Flutter)
- Android Studio / Xcode for device deployment
- Two or more Android devices (or emulators) on the same Wi-Fi or hotspot for live mesh testing

### 1. Clone the repository

```bash
git clone https://github.com/<your-org>/iTantra.git
cd iTantra
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Android permissions

The required permissions are declared in `android/app/src/main/AndroidManifest.xml`. Ensure the following are present:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE"/>
```

Runtime microphone permission is requested on first STT use via `permission_handler`.

### 4. Run on a physical Android device

```bash
flutter run --release
```

> **Note**: Real mesh peer discovery requires physical devices on the same network. Emulators share `127.0.0.1` loopback only and cannot discover each other via subnet broadcast.

### 5. Enable Simulation Mode (single-device demo)

1. Open the app and complete language selection.
2. Navigate to **Settings** tab.
3. Toggle **Simulation Mode** — three virtual peers appear immediately.
4. Use the walkie-talkie button or SOS to test the full pipeline on one device.

---

## Usage

### Onboarding Flow

1. **Language Selection Screen**: choose your primary language (the language you speak and want to hear in). The app initialises the mesh node with a derived node name (e.g., `Node-ML` for Malayalam).

2. **Mesh Home Screen**: displays discovered peers, your node's IP, live TX/RX packet counters, and the log stream. Tap **PING** to force-broadcast a beacon immediately.

3. **Transmitting Screen**: hold the mic button to speak. Your speech is recognised, translated to the English mesh pivot, broadcast, and each peer receives the translation in their own language automatically.

4. **SOS Screen**: tap **BROADCAST PRIORITY SOS** from any screen. The pre-loaded evacuation alert broadcasts with elevated TTL and interrupts all peer devices with an audio alert in their native language.

5. **Peers Screen**: lists all active mesh nodes with their language, estimated distance, hop count, and node ID.

6. **Settings Screen**: simulation mode toggle, binary/JSON protocol switch, relay enable/disable.

---

## Packet Protocol Reference

MeshCodec v3 binary frame layout:

```
Byte  Field
0     Magic: 0xAA
1     Protocol version: 0x03
2     Packet type (0=beacon, 1=voiceText, 2=prioritySos)
3–10  Timestamp (int64, big-endian)
11    Source language code (0–9, 255=ALL)
12    Target language code
13    Hop count
14    TTL
15–22 Latitude (float64, big-endian)
23–30 Longitude (float64, big-endian)
31    SenderID length (L1)
32…   SenderID (ASCII)
+L1   PacketID length (L2)
…     PacketID (ASCII)
+L2   SenderName length (L3)
…     SenderName (UTF-8)
+L3   Payload length (uint16, big-endian)
…     Payload UTF-8
```

Falls back to JSON encoding/decoding for legacy compatibility.

---

## Supported Disaster Scenarios

The pre-loaded sentence matrix covers the eight most critical real-field messages:

| Scenario | English Pivot Key |
|----------|-------------------|
| Mass evacuation to hilltop shelter | `evacuate immediately to shelter on hill top` |
| People trapped, rescue needed | `people trapped need immediate rescue` |
| Water and food supply request | `need drinking water and food packets` |
| Medical support request | `require medical support and doctor at checkpoint` |
| Rising water / flood alert | `water level rising flood alert` |
| Perimeter status normal | `status normal holding current perimeter` |
| Road and bridge infrastructure | `road blocked bridge collapsed` |
| Safety confirmation | `we are safe at current location` |

---

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── geo_engine.dart             # Haversine distance & bearing
├── ml_engine.dart              # Edge translation (English pivot)
├── speech_engine.dart          # TTS synthesis + phrase book
├── stt_service.dart            # Continuous STT dictation loop
├── transceiver_engine.dart     # UDP mesh networking & peer discovery
├── protocol/
│   └── mesh_codec.dart         # Binary packet encoder/decoder (v3)
└── screens/
    ├── localization_screen.dart  # Language selection onboarding
    ├── mesh_home_screen.dart     # Main transceiver dashboard
    ├── transmitting_screen.dart  # PTT / walkie-talkie UI
    ├── peers_screen.dart         # Discovered mesh nodes list
    ├── settings_screen.dart      # Simulation, protocol, relay settings
    └── sos_emergency_screen.dart # Priority SOS + tactical radar
```

---

## Team

Built for **Smart India Hackathon 2026** (PS26173) by Team iTantra.

---

## License

This project is released under the [MIT License](LICENSE).
