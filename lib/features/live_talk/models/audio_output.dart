/// State of the live talk session, and where its voice comes out.
enum LiveStatus { idle, listening, thinking, speaking }

/// Somewhere the voice can play: the phone speaker or connected headphones.
class AudioOutput {
  const AudioOutput({
    required this.id,
    required this.name,
    this.isSpeaker = false,
  });

  static const speaker = AudioOutput(id: 'speaker', name: '', isSpeaker: true);

  final String id;
  final String name;
  final bool isSpeaker;
}
