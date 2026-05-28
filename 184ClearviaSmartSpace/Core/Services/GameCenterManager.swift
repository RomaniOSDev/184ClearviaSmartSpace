import Combine
import Foundation
import GameKit
import UIKit

enum GameCenterLeaderboard: String {
    case endlessScore = "com.rhythm.endless.score"
    case totalStars = "com.rhythm.total.stars"

    var identifier: String { rawValue }
}

@MainActor
final class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()

    @Published private(set) var isAuthenticated = false
    @Published private(set) var localPlayerName: String?

    private init() {}

    func authenticateIfNeeded() {
        guard GKLocalPlayer.local.isAuthenticated == false else {
            isAuthenticated = true
            localPlayerName = GKLocalPlayer.local.displayName
            return
        }

        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let viewController {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let root = scene.windows.first?.rootViewController else { return }
                root.present(viewController, animated: true)
                return
            }
            if error == nil {
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                self?.localPlayerName = GKLocalPlayer.local.displayName
            }
        }
    }

    func submitEndlessScore(_ score: Int, activityId: String) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        GKLeaderboard.submitScore(
            score,
            context: activityId.hashValue,
            player: GKLocalPlayer.local,
            leaderboardIDs: [GameCenterLeaderboard.endlessScore.identifier]
        ) { _ in }
    }

    func submitTotalStars(_ stars: Int) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        GKLeaderboard.submitScore(
            stars,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [GameCenterLeaderboard.totalStars.identifier]
        ) { _ in }
    }

    func presentLeaderboards() {
        guard GKLocalPlayer.local.isAuthenticated else {
            authenticateIfNeeded()
            return
        }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        let controller = GKGameCenterViewController(state: .leaderboards)
        controller.gameCenterDelegate = GameCenterPresenter.shared
        root.present(controller, animated: true)
    }
}

private final class GameCenterPresenter: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterPresenter()

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
