import SwiftUI
import Combine

struct ActivityTutorialView: View {
    let activity: ActivityDefinition
    var onComplete: () -> Void

    @State private var step = 0

    private var steps: [(title: String, body: String, symbol: String)] {
        switch activity.id {
        case "harmony_pulse":
            return [
                ("Watch the Pulse", "A ring shrinks toward the highlighted note.", "circle.circle"),
                ("Tap on Beat", "Press the note when the ring closes and you see NOW!", "hand.tap.fill"),
                ("Build a Streak", "Land 5 perfect taps in a row to win.", "flame.fill")
            ]
        case "melody_glide":
            return [
                ("Match Colors", "Each note matches one colored lane.", "paintpalette.fill"),
                ("Drag to Lane", "Drop the note onto its matching path.", "arrow.down.circle.fill"),
                ("Glide Home", "Guide every note to the finish line.", "arrow.right.circle.fill")
            ]
        case "melody_hold":
            return [
                ("Hold the Note", "Press and hold falling notes.", "hand.point.up.left.fill"),
                ("Release on Time", "Let go when the bar fills for your color.", "timer"),
                ("Land Ten Notes", "Complete 10 accurate landings to win.", "checkmark.circle.fill")
            ]
        case "tap_sequence":
            return [
                ("Watch the Pattern", "Notes light up in order — watch closely.", "eye.fill"),
                ("Repeat It", "Tap the same notes in the same order.", "list.number"),
                ("Stay Sharp", "Sequences grow longer each level.", "sparkles")
            ]
        default:
            return [("Get Ready", "Complete the challenge to earn stars.", "star.fill")]
        }
    }

    var body: some View {
        ZStack {
            BackgroundPatternView()
            VStack(spacing: 24) {
                Spacer()
                SurfaceCard(accentBorder: true) {
                    VStack(spacing: 18) {
                        IconBadgeView(systemName: steps[step].symbol, size: 68, iconSize: 28)
                        Text("Step \(step + 1) of \(steps.count)")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                        Text(steps[step].title)
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .multilineTextAlignment(.center)
                        Text(steps[step].body)
                            .font(.body)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)

                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index == step ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.3))
                            .frame(width: index == step ? 22 : 8, height: 8)
                    }
                }

                Spacer()

                AppButton(
                    title: step < steps.count - 1 ? "Next" : "Start Playing",
                    icon: step < steps.count - 1 ? "arrow.right" : "play.fill"
                ) {
                    if step < steps.count - 1 {
                        withAnimation(.easeInOut(duration: 0.25)) { step += 1 }
                    } else {
                        onComplete()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}
