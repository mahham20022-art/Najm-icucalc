/// The two vendors the AI Engine supports — per
/// `MED100_ARCHITECTURE.md` §10.3's vendor-abstraction requirement, this
/// is the only place either vendor's name appears in the domain layer;
/// everything else talks to the generic [AiProvider] interface.
enum AiProviderId { openAi, claude }
