import SwiftUI

struct SettingsCell: View {
    let title: String
    let icon: String
    var subtitle: String?
    var destructive: Bool = false
    var action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            HapticService.lightTap()
            action()
        } label: {
            HStack(spacing: 14) {
                IconBadgeView(
                    systemName: icon,
                    size: 42,
                    iconSize: 18,
                    highlighted: !destructive
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(destructive ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                Spacer(minLength: 0)
                if !destructive {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextSecondary").opacity(0.7))
                }
            }
            .padding(12)
            .background(ElevatedSurfaceBackground(cornerRadius: 16))
            .appSoftShadow()
            .scaleEffect(pressed ? 0.98 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.12)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { pressed = false } }
        )
    }
}

struct LevelCell: View {
    let level: Int
    let stars: Int
    let unlocked: Bool
    let bestAccuracy: Double?
    var isPractice: Bool = false
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            guard unlocked else { return }
            HapticService.mediumTap()
            action()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            unlocked
                                ? LinearGradient(
                                    colors: [Color("AppPrimary").opacity(0.38), Color("AppPrimary").opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : AppGradients.surfaceInset
                        )
                        .frame(width: 46, height: 46)
                        .overlay(
                            Circle().stroke(unlocked ? AppGradients.accentBorder : AppGradients.subtleBorder, lineWidth: 1.5)
                        )
                    if unlocked {
                        Text("\(level + 1)")
                            .font(.title3.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                StarRatingView(count: stars, size: 11)
                if let bestAccuracy, bestAccuracy > 0 {
                    Text("\(Int(bestAccuracy * 100))%")
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppAccent"))
                } else if isPractice && unlocked {
                    Text("Practice")
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(ElevatedSurfaceBackground(cornerRadius: 16, accentBorder: unlocked))
            .appSoftShadow()
            .opacity(unlocked ? 1 : 0.55)
            .scaleEffect(pressed && unlocked ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if unlocked { withAnimation(.easeInOut(duration: 0.12)) { pressed = true } }
                }
                .onEnded { _ in withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { pressed = false } }
        )
    }
}

struct AchievementCell: View {
    let achievement: AchievementDefinition
    let unlocked: Bool
    let progress: AchievementProgress
    var animated: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            HapticService.lightTap()
            action()
        } label: {
            VStack(spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    IconBadgeView(
                        systemName: achievement.isHidden && !unlocked ? "questionmark" : achievement.iconName,
                        size: 58,
                        iconSize: 24,
                        highlighted: unlocked
                    )
                    .scaleEffect(animated ? 1.12 : 1)
                    if unlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color("AppPrimary"))
                            .offset(x: 4, y: -4)
                    }
                }

                Text(achievement.displayTitle(unlocked: unlocked))
                    .font(.subheadline.bold())
                    .foregroundStyle(unlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(achievement.displayDescription(unlocked: unlocked))
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(minHeight: 32)

                if !unlocked {
                    ProgressBarView(fraction: progress.fraction, height: 5)
                    Text(progress.label)
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppAccent"))
                } else {
                    StatusPillView(text: "Unlocked", style: .success)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 188)
            .background(ElevatedSurfaceBackground(cornerRadius: 18, accentBorder: unlocked))
            .appSoftShadow()
            .opacity(unlocked ? 1 : 0.82)
        }
        .buttonStyle(.plain)
    }
}

struct ActivityStatCell: View {
    let stat: ActivityBreakdownStat
  let iconName: String

    var body: some View {
        HStack(spacing: 12) {
            IconBadgeView(systemName: iconName, size: 40, iconSize: 17)
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(stat.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    HStack(spacing: 3) {
                        Text("\(stat.totalStars)")
                            .font(.caption.bold())
                        Image(systemName: "star.fill")
                            .font(.caption2)
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
                HStack(spacing: 8) {
                    Label("\(stat.sessions)", systemImage: "play.fill")
                    Text("•")
                    Text("Avg \(Int(stat.averageAccuracy * 100))%")
                }
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
        }
        .padding(12)
        .background(ElevatedSurfaceBackground(cornerRadius: 14, inset: true))
    }
}

struct ProgressBarView: View {
    let fraction: Double
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color("AppBackground").opacity(0.7))
                Capsule()
                    .fill(Color("AppPrimary"))
                    .frame(width: geo.size.width * fraction)
            }
        }
        .frame(height: height)
    }
}

struct DifficultyPickerView: View {
    @Binding var selection: Difficulty
    let options: [Difficulty]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options) { difficulty in
                let selected = selection == difficulty
                Button {
                    HapticService.lightTap()
                    withAnimation(.easeInOut(duration: 0.25)) { selection = difficulty }
                } label: {
                    Text(difficulty.rawValue)
                        .font(.caption.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(selected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    selected
                                        ? AppGradients.primaryButton
                                        : AppGradients.surfaceInset
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(
                                            selected ? AppGradients.accentBorder : AppGradients.subtleBorder,
                                            lineWidth: 1
                                        )
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ThemeOptionCell: View {
    let theme: AppTheme
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticService.lightTap()
            action()
        } label: {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Circle().fill(Color(theme.palette.primary)).frame(width: 14, height: 14)
                    Circle().fill(Color(theme.palette.accent)).frame(width: 14, height: 14)
                    Circle().fill(Color(theme.palette.surface)).frame(width: 14, height: 14)
                }
                Text(theme.title)
                    .font(.caption.bold())
                    .foregroundStyle(selected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(ElevatedSurfaceBackground(cornerRadius: 14, accentBorder: selected))
            .appSoftShadow(radius: selected ? 5 : 3, y: selected ? 2 : 1)
        }
        .buttonStyle(.plain)
    }
}

struct ModeToggleCell: View {
    @Binding var isOn: Bool
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            IconBadgeView(systemName: icon, size: 42, iconSize: 18, highlighted: isOn)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("AppPrimary"))
        }
        .padding(14)
        .background(ElevatedSurfaceBackground(cornerRadius: 16, accentBorder: isOn))
        .appSoftShadow()
        .onChange(of: isOn) { _ in HapticService.lightTap() }
    }
}
