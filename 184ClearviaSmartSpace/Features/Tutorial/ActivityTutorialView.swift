import SwiftUI
import Combine

struct ActivityTutorialView: View {
    let activity: ActivityDefinition
    var onComplete: () -> Void

    @State private var step = 0

    private var steps: [(title: String, body: String, symbol: String)] {
        ActivityHintProvider.tutorialSteps(activityId: activity.id)
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
