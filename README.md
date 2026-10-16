# iTantra

iTantra is a **Smart India Hackathon (SIH) Problem Statement PS26173** prototype for offline disaster communication.

It demonstrates a multilingual, mesh-enabled emergency communication system where nearby devices can exchange voice-derived text and SOS alerts even when regular network connectivity is unstable.

## SIH PS26173 Overview

This repository implements a concept aligned to **SIH PS26173**:
- resilient, local-first communication during disaster scenarios
- multilingual message interoperability for Indian languages
- emergency broadcast support over peer-to-peer / mesh-style propagation
- location-aware alerting and responder visibility

## Problem Explainer Video

- YouTube: https://www.youtube.com/watch?v=S2vu6kKMsqM

## Core Features

- **10-language support (per PS26173 flow):** Malayalam, Hindi, Gujarati, Marathi, Kannada, Tamil, Telugu, Odia, Bengali, English
- **Offline translation pipeline:** local English pivot model flow in `lib/ml_engine.dart`
- **Voice input + speech output:** STT (`speech_to_text`) + TTS (`flutter_tts`)
- **Mesh transport engine:** UDP broadcast peer discovery, packet exchange, and relay hops
- **Binary mesh protocol:** compact packet codec with geo-telemetry in `lib/protocol/mesh_codec.dart`
- **Priority SOS flow:** high-priority emergency broadcast with dedicated alert screen
- **Geo context:** distance and bearing calculations for tactical awareness
- **Judge/demo mode:** simulated multi-hop peers for SIH-style demonstrations
- **Operational dashboard:** packet TX/RX counters, node visibility, relay and simulation toggles

## App Flow

1. Select node language (`LocalizationScreen`)
2. Start local transceiver node (`TransceiverEngine.start`)
3. Discover mesh peers (`MeshHomeScreen` / `PeersScreen`)
4. Capture speech and map to English pivot (`TransmittingScreen` + `EdgeMlEngine`)
5. Broadcast to all nodes and auto-render in each node’s local language
6. Receive and process high-priority SOS with audible alerts and geodesic radar view

## Tech Stack

- **Framework:** Flutter (Dart SDK `>=3.2.0 <4.0.0`)
- **Speech:** `speech_to_text`, `flutter_tts`
- **Permissions:** `permission_handler`
- **Networking:** Dart `RawDatagramSocket` UDP broadcast
- **Targets:** Android, iOS, Web, Linux, macOS, Windows (Flutter scaffolded)

## Repository Structure

- `/home/runner/work/iTantra/iTantra/lib/main.dart` — app entry and theme
- `/home/runner/work/iTantra/iTantra/lib/screens/` — UI screens and interaction flow
- `/home/runner/work/iTantra/iTantra/lib/transceiver_engine.dart` — mesh networking core
- `/home/runner/work/iTantra/iTantra/lib/ml_engine.dart` — offline multilingual translation logic
- `/home/runner/work/iTantra/iTantra/lib/speech_engine.dart` — TTS engine
- `/home/runner/work/iTantra/iTantra/lib/stt_service.dart` — STT service + mic permission
- `/home/runner/work/iTantra/iTantra/lib/geo_engine.dart` — distance and bearing utilities
- `/home/runner/work/iTantra/iTantra/lib/protocol/mesh_codec.dart` — binary packet codec

## Setup Guide

### Prerequisites

- Flutter SDK installed and available on PATH
- Dart SDK compatible with `>=3.2.0 <4.0.0`
- Android Studio / Xcode / platform toolchains as needed

### Install

```bash
cd /home/runner/work/iTantra/iTantra
flutter pub get
```

### Run

```bash
flutter run
```

To test mesh behavior, run the app on multiple devices connected to the same hotspot/Wi-Fi network.

## Testing

Run existing tests:

```bash
flutter test
```

Current repository test coverage includes a basic smoke test in:
- `/home/runner/work/iTantra/iTantra/test/widget_test.dart`

## Notes

- Android permissions for internet, audio, and Wi-Fi state are declared in `android/app/src/main/AndroidManifest.xml`.
- The app includes fallback/simulated behavior to support demos even without full field hardware.
