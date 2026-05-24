import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdownContent = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPatternView()
                ScrollView {
                    if markdownContent.isEmpty {
                        SurfaceCard {
                            Text("Privacy Policy could not be loaded.")
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .padding(20)
                    } else {
                        SurfaceCard {
                            Group {
                                if let attributed = attributedPolicyText {
                                    Text(attributed)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                        .tint(Color("AppPrimary"))
                                } else {
                                    Text(markdownContent)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        HapticService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear { loadPolicy() }
        }
        .tint(Color("AppPrimary"))
    }

    private var attributedPolicyText: AttributedString? {
        try? AttributedString(
            markdown: markdownContent,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        )
    }

    private func loadPolicy() {
        if let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            markdownContent = content
        }
    }
}
