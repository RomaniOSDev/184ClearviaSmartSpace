import Foundation
import UIKit

enum AppLink: String, CaseIterable {
    case privacyPolicy = "https://clearviasmart184space.site/privacy/204"
    case termsOfUse = "https://clearviasmart184space.site/terms/204"

    var title: String {
        switch self {
        case .privacyPolicy: "Privacy Policy"
        case .termsOfUse: "Terms of Use"
        }
    }

    var url: URL? {
        URL(string: rawValue)
    }

    func open() {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
