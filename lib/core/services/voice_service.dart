import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import '../storage/storage_service.dart';

/// One of the voices the assistant can speak with, picked in Voice
/// Preferences. The device's text to speech voices differ per phone, so a
/// voice is a pitch and pace on top of one of the installed English voices.
class AssistantVoice {
  const AssistantVoice({
    required this.id,
    required this.name,
    required this.taglineKey,
    required this.isMale,
    required this.pitch,
    required this.rate,
  });

  final String id;
  final String name;
  final String taglineKey;
  final bool isMale;

  /// 1 is the engine's normal pitch.
  final double pitch;

  /// 0.5 is the normal pace on both Android and iOS.
  final double rate;
}

/// Which voice the assistant speaks with, shared by Live Talk, reading
/// replies aloud and the Voice Preferences preview.
class VoiceService {
  VoiceService._();

  static final VoiceService instance = VoiceService._();

  static const voices = [
    AssistantVoice(
      id: 'victor',
      name: 'Victor',
      taglineKey: 'voice_tagline_victor',
      isMale: true,
      pitch: 0.95,
      rate: 0.5,
    ),
    AssistantVoice(
      id: 'aria',
      name: 'Aria',
      taglineKey: 'voice_tagline_aria',
      isMale: false,
      pitch: 1.1,
      rate: 0.52,
    ),
    AssistantVoice(
      id: 'orion',
      name: 'Orion',
      taglineKey: 'voice_tagline_orion',
      isMale: true,
      pitch: 0.8,
      rate: 0.45,
    ),
    AssistantVoice(
      id: 'luna',
      name: 'Luna',
      taglineKey: 'voice_tagline_luna',
      isMale: false,
      pitch: 1.2,
      rate: 0.56,
    ),
  ];

  late final selected = _saved().obs;

  static AssistantVoice _saved() {
    final id = StorageService.instance.getString(StorageService.voiceKey);
    return voices.firstWhere((v) => v.id == id, orElse: () => voices.first);
  }

  Future<void> select(AssistantVoice voice) async {
    selected.value = voice;
    await StorageService.instance.setString(StorageService.voiceKey, voice.id);
  }

  /// The installed English voices, loaded once.
  List<Map<String, String>>? _installed;

  /// Sets [tts] up to speak as [voice], the selected one by default.
  Future<void> apply(FlutterTts tts, [AssistantVoice? voice]) async {
    voice ??= selected.value;
    try {
      final installed = _installed ??= await _loadInstalled(tts);
      final match = _systemVoiceFor(voice, installed);
      if (match != null) await tts.setVoice(match);
      await tts.setPitch(voice.pitch);
      await tts.setSpeechRate(voice.rate);
    } catch (_) {
      // The engine's default voice still works.
    }
  }

  static Future<List<Map<String, String>>> _loadInstalled(
    FlutterTts tts,
  ) async {
    final raw = await tts.getVoices;
    if (raw is! List) return const [];
    final found = <Map<String, String>>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final voice = item.map((k, v) => MapEntry('$k', '$v'));
      final locale = (voice['locale'] ?? '').toLowerCase().replaceAll('_', '-');
      if (voice['name'] == null || !locale.startsWith('en')) continue;
      // Android lists voices that need a download or the network to speak.
      if (voice['network_required'] == '1' ||
          voice['features']?.contains('notInstalled') == true) {
        continue;
      }
      found.add(voice);
    }
    // US voices first, then a stable order so each voice keeps its match.
    int rank(Map<String, String> v) =>
        v['locale']!.toLowerCase().replaceAll('_', '-') == 'en-us' ? 0 : 1;
    found.sort((a, b) {
      final byLocale = rank(a) - rank(b);
      return byLocale != 0 ? byLocale : a['name']!.compareTo(b['name']!);
    });
    return found;
  }

  /// A different installed voice per assistant voice where the phone has
  /// enough, matching gender where the platform reports it (iOS).
  static Map<String, String>? _systemVoiceFor(
    AssistantVoice voice,
    List<Map<String, String>> installed,
  ) {
    if (installed.isEmpty) return null;
    final gender = voice.isMale ? 'male' : 'female';
    final sameGender = installed
        .where((v) => v['gender']?.toLowerCase() == gender)
        .toList();
    final pool = sameGender.isNotEmpty ? sameGender : installed;
    final peers = voices.where(
      (v) => sameGender.isEmpty || v.isMale == voice.isMale,
    );
    final slot = peers.toList().indexOf(voice);
    final picked = pool[slot % pool.length];
    return {'name': picked['name']!, 'locale': picked['locale']!};
  }
}
