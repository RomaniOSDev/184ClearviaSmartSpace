import SwiftUI

struct BackgroundPatternView: View {
    @Environment(\.themePalette) private var palette

    var body: some View {
        ZStack {
            AppGradients.screenBase(background: palette.background, surface: palette.surface)

            AmbientGlowLayer()

            LinearGradient(
                colors: [Color.clear, Color(palette.background).opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .drawingGroup(opaque: false)
        .ignoresSafeArea()
    }
}
