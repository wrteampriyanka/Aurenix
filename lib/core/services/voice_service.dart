import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/storage/storage_service.dart';
import 'package:aurenix/core/constants/app_strings.dart';

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
    required this.fallbackPitch,
    required this.rate,
  });

  final String id;
  final String name;
  final String taglineKey;
  final bool isMale;

  /// 1 is the engine's normal pitch.
  final double pitch;

  /// Used instead of [pitch] when no installed voice of the right gender
  /// was found, so a boy still sounds lower than a girl.
  final double fallbackPitch;

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
      taglineKey: AppStrings.voiceTaglineVictor,
      isMale: true,
      pitch: 1.0,
      fallbackPitch: 0.75,
      rate: 0.5,
    ),
    AssistantVoice(
      id: 'aria',
      name: 'Aria',
      taglineKey: AppStrings.voiceTaglineAria,
      isMale: false,
      pitch: 1.05,
      fallbackPitch: 1.2,
      rate: 0.52,
    ),
    AssistantVoice(
      id: 'orion',
      name: 'Orion',
      taglineKey: AppStrings.voiceTaglineOrion,
      isMale: true,
      pitch: 0.9,
      fallbackPitch: 0.62,
      rate: 0.45,
    ),
    AssistantVoice(
      id: 'luna',
      name: 'Luna',
      taglineKey: AppStrings.voiceTaglineLuna,
      isMale: false,
      pitch: 1.15,
      fallbackPitch: 1.35,
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

  // ---------------------------------------------------------------------
  // The engine.
  //
  // One [FlutterTts] for the whole app. There is only one native engine, so
  // three instances were three handles on the same thing: whoever spoke last
  // owned the error handler, and stopping one stopped the others without
  // their knowing. Everything goes through [speak] and [stop] now, and a run
  // counter says whose turn it still is.
  // ---------------------------------------------------------------------

  final _tts = FlutterTts();

  /// Bumped by [stop] and by each new [speak], so a speak that has been
  /// taken over can tell and give up quietly.
  int _run = 0;

  bool _configured = false;

  /// Sets the engine up once per app run. Each speak call returns only once
  /// it has been read out. On iOS it plays through the speaker even in
  /// silent mode and after the mic has set up recording.
  Future<void> _configure() async {
    if (_configured) return;
    _configured = true;
    _tts.setErrorHandler((_) => _run++);
    await _tts.awaitSpeakCompletion(true);
    if (GetPlatform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ], IosTextToSpeechAudioMode.spokenAudio);
    }
  }

  /// Reads [text] aloud in [voice], the selected one by default.
  ///
  /// Returns true once the whole text has been read, false if another caller
  /// started speaking or [stop] was called part way through. Throws if the
  /// engine refuses to speak.
  Future<bool> speak(String text, {AssistantVoice? voice}) async {
    final run = ++_run;
    await _configure();
    if (run != _run) return false;
    await apply(_tts, voice);
    for (final part in speechParts(text)) {
      if (run != _run) return false;
      if (await _tts.speak(part) != 1) throw Exception('speak failed');
    }
    return run == _run;
  }

  /// Stops whatever is being read out. Any [speak] still running returns
  /// false rather than finishing.
  Future<void> stop() async {
    _run++;
    await _tts.stop();
  }

  /// Splits [text] at sentence ends into parts short enough for Android,
  /// which refuses to read long text in one go.
  static List<String> speechParts(String text, {int maxLength = 1000}) {
    final parts = <String>[];
    var current = '';
    for (final sentence in text.split(RegExp(r'(?<=[.!?\n])\s+'))) {
      if (current.isNotEmpty &&
          current.length + sentence.length + 1 > maxLength) {
        parts.add(current);
        current = '';
      }
      current = current.isEmpty ? sentence : '$current $sentence';
      while (current.length > maxLength) {
        parts.add(current.substring(0, maxLength));
        current = current.substring(maxLength);
      }
    }
    if (current.trim().isNotEmpty) parts.add(current);
    return parts;
  }

  /// Markdown without the symbols, so they are neither shown nor read out.
  static String plainText(String markdown) => markdown
      .replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (m) => m[1]!)
      .replaceAll(RegExp(r'[*_#`>|~]'), '')
      .replaceAll(RegExp(r'^\s*[-+]\s+', multiLine: true), '')
      .trim();

  /// The installed voice each assistant voice speaks with, by id, worked
  /// out once. Missing when the phone has no voice left to give it.
  Map<String, _SystemVoice>? _assigned;

  /// Sets [tts] up to speak as [voice], the selected one by default.
  Future<void> apply(FlutterTts tts, [AssistantVoice? voice]) async {
    voice ??= selected.value;
    try {
      final assigned = _assigned ??= _assign(await _loadInstalled(tts));
      final match = assigned[voice.id];
      if (match != null) {
        await tts.setVoice({'name': match.name, 'locale': match.locale});
      }
      // A voice of the right gender sounds right as it is; otherwise the
      // pitch has to carry the boy or girl sound.
      final genderMatched = match?.isMale == voice.isMale;
      await tts.setPitch(genderMatched ? voice.pitch : voice.fallbackPitch);
      await tts.setSpeechRate(voice.rate);
    } catch (_) {
      // The engine's default voice still works.
    }
  }

  /// Gives each assistant voice its own installed voice, boys a male one
  /// and girls a female one where the phone has them. No installed voice
  /// is used twice.
  static Map<String, _SystemVoice> _assign(List<_SystemVoice> installed) {
    final used = <String>{};
    final assigned = <String, _SystemVoice>{};
    _SystemVoice? take(bool Function(_SystemVoice) test) {
      for (final v in installed) {
        if (!used.contains(v.speaker) && test(v)) {
          used.add(v.speaker);
          return v;
        }
      }
      return null;
    }

    // Matching genders first, so a boy never takes the only female voice.
    for (final voice in voices) {
      final match = take((v) => v.isMale == voice.isMale);
      if (match != null) assigned[voice.id] = match;
    }
    for (final voice in voices) {
      if (assigned.containsKey(voice.id)) continue;
      final match = take((v) => v.isMale == null) ?? take((_) => true);
      if (match != null) assigned[voice.id] = match;
    }
    return assigned;
  }

  static Future<List<_SystemVoice>> _loadInstalled(FlutterTts tts) async {
    final raw = await tts.getVoices;
    if (raw is! List) return const [];
    final bySpeaker = <String, _SystemVoice>{};
    for (final item in raw) {
      if (item is! Map) continue;
      final map = item.map((k, v) => MapEntry('$k', '$v'));
      final voice = _SystemVoice.from(map);
      if (voice == null) continue;
      // Android lists each speaker twice, on device and online; keep the
      // better one.
      final seen = bySpeaker[voice.speaker];
      if (seen == null || voice.rank < seen.rank) {
        bySpeaker[voice.speaker] = voice;
      }
    }
    return bySpeaker.values.toList()..sort((a, b) => a.rank - b.rank);
  }
}

/// An English voice installed on the phone.
class _SystemVoice {
  const _SystemVoice({
    required this.name,
    required this.locale,
    required this.speaker,
    required this.isMale,
    required this.rank,
  });

  final String name;
  final String locale;

  /// Who is speaking, the same for the on device and online copies.
  final String speaker;

  /// Null when neither the platform nor [_maleNames]/[_femaleNames] say.
  final bool? isMale;

  /// Lower is better: US English, then other accents; good quality first.
  final int rank;

  static _SystemVoice? from(Map<String, String> v) {
    final name = v['name'];
    final locale = v['locale'];
    if (name == null || locale == null) return null;
    final lang = locale.toLowerCase().replaceAll('_', '-');
    if (!lang.startsWith('en')) return null;
    final id = (v['identifier'] ?? '').toLowerCase();
    // iOS joke voices (Bubbles, Zarvox, …) and the robotic Eloquence ones.
    if (id.contains('speech.synthesis.voice') || id.contains('eloquence')) {
      return null;
    }
    if (_skipNames.contains(name.toLowerCase())) return null;
    if (v['features']?.contains('notInstalled') == true) return null;

    final online =
        v['network_required'] == '1' ||
        v['network_required'] == 'true' ||
        name.endsWith('-network');
    // Google voices are named like en-us-x-iom-local; "iom" is the speaker.
    final code = RegExp(r'-x-([a-z]+)').firstMatch(name.toLowerCase())?[1];
    final speaker = code != null
        ? '${lang.substring(0, lang.length.clamp(0, 5))}-$code'
        : name.toLowerCase();

    final gender = (v['gender'] ?? '').toLowerCase();
    final firstName = name.split(RegExp(r'[\s(]')).first.toLowerCase();
    final bool? isMale = switch (gender) {
      'male' => true,
      'female' => false,
      _ when _maleNames.contains(code ?? firstName) => true,
      _ when _femaleNames.contains(code ?? firstName) => false,
      _ => null,
    };

    final quality = v['quality']?.toLowerCase() ?? '';
    final good =
        quality == 'premium' ||
        quality == 'enhanced' ||
        (int.tryParse(quality) ?? 0) >= 400;
    final accent = switch (lang) {
      'en-us' => 0,
      'en-gb' => 1,
      'en-au' => 2,
      _ => 3,
    };
    return _SystemVoice(
      name: name,
      locale: locale,
      speaker: speaker,
      isMale: isMale,
      rank: (online ? 100 : 0) + accent * 10 + (good ? 0 : 1),
    );
  }

  /// Google speaker codes and Apple voice names known to be male.
  static const _maleNames = {
    'iol', 'iom', 'tpd', 'gbb', 'gbd', 'rjs', 'aub', 'aud', //
    'daniel', 'aaron', 'arthur', 'gordon', 'rishi', 'alex', 'evan',
    'nathan', 'tom', 'oliver', 'lee', 'james', 'malcolm',
  };

  /// Google speaker codes and Apple voice names known to be female.
  static const _femaleNames = {
    'iob', 'iog', 'sfg', 'tpc', 'tpf', 'gba', 'gbc', 'gbg', 'afh', 'aua',
    'auc', //
    'samantha', 'karen', 'moira', 'tessa', 'martha', 'catherine', 'nicky',
    'zoe', 'ava', 'allison', 'susan', 'serena', 'kate', 'fiona', 'veena',
    'victoria', 'joelle', 'noelle',
  };

  /// iOS novelty voices, in case the identifier doesn't give them away.
  static const _skipNames = {
    'albert',
    'bad news',
    'bahh',
    'bells',
    'boing',
    'bubbles',
    'cellos',
    'good news',
    'jester',
    'organ',
    'superstar',
    'trinoids',
    'whisper',
    'wobble',
    'zarvox',
    'junior',
    'ralph',
    'kathy',
    'fred',
    'eddy',
    'flo',
    'grandma',
    'grandpa',
    'reed',
    'rocko',
    'sandy',
    'shelley',
  };
}
