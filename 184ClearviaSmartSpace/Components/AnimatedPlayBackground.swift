import SwiftUI

/// Lightweight static overlay — no TimelineView to avoid scroll jank.
struct AnimatedPlayBackground: View {
    var body: some View {
        AmbientGlowLayer()
            .opacity(0.65)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}
