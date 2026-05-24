import SwiftUI

struct ComboCounterView: View {
    let combo: Int
    var label: String = "Combo"

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.fill")
                .foregroundStyle(Color("AppAccent"))
            Text("\(label): \(combo)")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(AppGradients.surface)
                .overlay(
                    Capsule().stroke(
                        combo > 0 ? AppGradients.accentBorder : AppGradients.subtleBorder,
                        lineWidth: 1
                    )
                )
        )
        .appSoftShadow(radius: combo >= 5 ? 8 : 3, y: combo >= 5 ? 3 : 1)
        .scaleEffect(combo > 0 && combo % 5 == 0 ? 1.08 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: combo)
    }
}
