import SwiftUI

struct InGameHintBar: View {
    let text: String
    @State private var expanded = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                Text(text)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(expanded ? 4 : 1)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.caption2.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(ElevatedSurfaceBackground(cornerRadius: 12, inset: true))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }
}
