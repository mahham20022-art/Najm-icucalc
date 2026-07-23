/// How the learner delivered their teach-back explanation. Both modes
/// converge on the same plain-text `explanationText` before evaluation
/// — Voice Explanation is speech-to-text transcription feeding the same
/// pipeline Written Explanation uses directly — but the mode is kept on
/// the record since a rushed voice transcript and a considered written
/// answer aren't quite the same kind of evidence.
enum ExplanationMode { voice, written }
