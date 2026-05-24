import SwiftUI
import Combine

struct StarRatingView: View {
    let count: Int
    var maxStars: Int = 3
    var size: CGFloat = 16
    var animated: Bool = false
    var visibleCount: Int?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxStars, id: \.self) { index in
                let filled = index < (visibleCount ?? count)
                Image(systemName: filled ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(filled ? Color("AppAccent") : Color("AppTextSecondary"))
                    .shadow(
                        color: filled && animated ? Color("AppAccent").opacity(0.6) : .clear,
                        radius: filled && animated ? 6 : 0
                    )
                    .scaleEffect(filled && animated ? 1.1 : 1.0)
                    .animation(
                        animated
                            ? .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.15)
                            : .default,
                        value: visibleCount ?? count
                    )
            }
        }
    }
}
