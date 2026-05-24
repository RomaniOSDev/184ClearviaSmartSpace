import SwiftUI

struct ActivityGameHost: View {
    let config: GameSessionConfig

    var body: some View {
        switch config.activityId {
        case "harmony_pulse":
            HarmonyPulseView(config: config)
        case "melody_glide":
            MelodyGlideView(config: config)
        case "melody_hold":
            MelodyHoldView(config: config)
        case "tap_sequence":
            TapSequenceView(config: config)
        default:
            EmptyView()
        }
    }
}
