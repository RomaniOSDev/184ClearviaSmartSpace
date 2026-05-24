import Foundation
import UIKit

enum AppLink: String, CaseIterable {
    case privacyPolicy = "https://example.com/privacy-policy"
    case termsOfUse = "https://example.com/terms-of-use"

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
