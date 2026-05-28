import Foundation

enum GameSessionCoordinator {
  /// Returns true when the session was handled externally (no result screen).
    static func reportCompletion(config: GameSessionConfig, success: Bool) -> Bool {
        switch config.mode {
        case .speedRun:
            NotificationCenter.default.post(
                name: .speedRunLevelComplete,
                object: nil,
                userInfo: ["success": success]
            )
            return true
        case .endless:
            NotificationCenter.default.post(
                name: .endlessWaveComplete,
                object: nil,
                userInfo: ["success": success]
            )
            return true
        default:
            return false
        }
    }
}
