import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: "Home"
        case .achievements: "Achievements"
        case .settings: "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home: "house.fill"
        case .achievements: "trophy.fill"
        case .settings: "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppGradients.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppGradients.subtleBorder, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppGradients.topHighlight, lineWidth: 1)
                )
        )
        .appElevationShadow(radius: 14, y: 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func tabButton(for tab: MainTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            HapticService.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 20, weight: .semibold))
                Text(tab.title)
                    .font(.caption2.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppGradients.primaryButton)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(AppGradients.topHighlight, lineWidth: 1)
                            )
                    }
                }
            )
            .scaleEffect(isSelected ? 1.0 : 0.94)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}
