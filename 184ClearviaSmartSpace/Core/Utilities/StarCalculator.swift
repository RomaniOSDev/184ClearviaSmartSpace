import Foundation

enum StarCalculator {
    static func stars(for accuracy: Double) -> Int {
        if accuracy >= 0.95 { return 3 }
        if accuracy >= 0.85 { return 2 }
        if accuracy >= 0.70 { return 1 }
        return 0
    }
}
