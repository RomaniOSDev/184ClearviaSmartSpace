import SwiftUI

struct DuelModeView: View {
  @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var playerOneScore = 0
    @State private var playerTwoScore = 0
    @State private var activePlayer = 1
    @State private var round = 1
    @State private var phase: DuelPhase = .intro
    @State private var sequence: [Int] = []
    @State private var inputIndex = 0
    @State private var highlighted: Int?
    @State private var showingPattern = false

    private let notes = ["C", "D", "E", "F", "G", "A"]
    private let maxRounds = 5

    enum DuelPhase {
        case intro, showing, input, roundResult, finished
    }

    var body: some View {
        ZStack {
            BackgroundPatternView()
            ScrollView {
                VStack(spacing: 18) {
                    SectionHeaderView(
                        title: "Local Duel",
                        subtitle: "Pass the device — best of \(maxRounds) rounds",
                        iconName: "person.2.fill"
                    )

                    scoreboard

                    if phase == .intro {
                        introCard
                    } else if phase == .finished {
                        finishedCard
                    } else {
                        duelBoard
                    }

                    if phase == .showing || phase == .input {
                        Text(showingPattern ? "Memorize the pattern" : "Player \(activePlayer): repeat the pattern")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Duel")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var scoreboard: some View {
        HStack(spacing: 12) {
            playerCard(name: "Player 1", score: playerOneScore, active: activePlayer == 1)
            playerCard(name: "Player 2", score: playerTwoScore, active: activePlayer == 2)
        }
    }

    private func playerCard(name: String, score: Int, active: Bool) -> some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
            Text("\(score)")
                .font(.title.bold())
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(ElevatedSurfaceBackground(cornerRadius: 16, accentBorder: active))
        .appSoftShadow()
    }

    private var introCard: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("How to play")
                    .font(.headline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Each round shows a note pattern. Players take turns repeating it. A mistake gives the round to the opponent.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                AppButton(title: "Start Duel", icon: "play.fill") {
                    startRound()
                }
            }
        }
    }

    private var duelBoard: some View {
        SurfaceCard(accentBorder: true) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(notes.indices, id: \.self) { index in
                    Button {
                        tapNote(index)
                    } label: {
                        Text(notes[index])
                            .font(.headline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        highlighted == index
                                            ? AppGradients.primaryButton
                                            : AppGradients.surfaceInset
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(phase != .input)
                }
            }
        }
    }

    private var finishedCard: some View {
        VStack(spacing: 14) {
            SurfaceCard(accentBorder: true) {
                VStack(spacing: 8) {
                    Text(winnerText)
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Final score \(playerOneScore) – \(playerTwoScore)")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .frame(maxWidth: .infinity)
            }
            AppButton(title: "Play Again", icon: "arrow.clockwise") {
                resetDuel()
            }
            AppButton(title: "Done", icon: "checkmark", style: .secondary) { dismiss() }
        }
    }

    private var winnerText: String {
        if playerOneScore == playerTwoScore { return "Draw!" }
        return playerOneScore > playerTwoScore ? "Player 1 Wins!" : "Player 2 Wins!"
    }

    private func startRound() {
        round = 1
        playerOneScore = 0
        playerTwoScore = 0
        activePlayer = 1
        beginPattern()
    }

    private func resetDuel() {
        phase = .intro
        sequence = []
        inputIndex = 0
    }

    private func beginPattern() {
        phase = .showing
        showingPattern = true
        inputIndex = 0
        sequence = (0..<(3 + round)).map { _ in Int.random(in: 0..<notes.count) }
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            for note in sequence {
                highlighted = note
                try? await Task.sleep(nanoseconds: 450_000_000)
            }
            highlighted = nil
            showingPattern = false
            phase = .input
        }
    }

    private func tapNote(_ index: Int) {
        guard phase == .input else { return }
        HapticService.lightTap()
        if sequence[inputIndex] == index {
            inputIndex += 1
            if inputIndex >= sequence.count {
                awardRound(to: activePlayer)
            }
        } else {
            awardRound(to: activePlayer == 1 ? 2 : 1)
        }
    }

    private func awardRound(to player: Int) {
        if player == 1 { playerOneScore += 1 } else { playerTwoScore += 1 }
        if round >= maxRounds {
            phase = .finished
            if playerOneScore != playerTwoScore {
                progress.recordDuelWin()
            }
            return
        }
        round += 1
        activePlayer = activePlayer == 1 ? 2 : 1
        beginPattern()
    }
}
