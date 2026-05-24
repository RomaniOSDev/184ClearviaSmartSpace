import Combine
import Foundation

final class ProgressStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let totalStarsEarned = "totalStarsEarned"
        static let totalPlayTimeSeconds = "totalPlayTimeSeconds"
        static let starsPerActivity = "starsPerActivity"
        static let unlockedLevels = "unlockedLevels"
        static let streakCount = "streakCount"
        static let personalBests = "personalBests"
        static let dailyChallengeDay = "dailyChallengeDay"
        static let dailyChallengeCompleted = "dailyChallengeCompleted"
        static let totalDailyChallengesCompleted = "totalDailyChallengesCompleted"
        static let lastPlayDay = "lastPlayDay"
        static let playStreakDays = "playStreakDays"
        static let activitySessions = "activitySessions"
        static let activityAccuracySum = "activityAccuracySum"
        static let completedTutorials = "completedTutorials"
        static let selectedTheme = "selectedTheme"
        static let expertUnlockedActivities = "expertUnlockedActivities"
        static let speedRunBests = "speedRunBests"
        static let bestComboOverall = "bestComboOverall"
        static let playDaysLog = "playDaysLog"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalActivitiesPlayed: Int {
        didSet { defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed) }
    }

    @Published var totalStarsEarned: Int {
        didSet { defaults.set(totalStarsEarned, forKey: Keys.totalStarsEarned) }
    }

    @Published var totalPlayTimeSeconds: Int {
        didSet { defaults.set(totalPlayTimeSeconds, forKey: Keys.totalPlayTimeSeconds) }
    }

    @Published var starsPerActivity: [String: [String: [Int]]] {
        didSet { saveDictionary(starsPerActivity, forKey: Keys.starsPerActivity) }
    }

    @Published var unlockedLevels: [String: [String: Int]] {
        didSet { saveUnlockedLevels(unlockedLevels, forKey: Keys.unlockedLevels) }
    }

    @Published var streakCount: Int {
        didSet { defaults.set(streakCount, forKey: Keys.streakCount) }
    }

    @Published var personalBests: [String: PersonalBestRecord] {
        didSet { savePersonalBests(personalBests, forKey: Keys.personalBests) }
    }

    @Published var dailyChallengeDay: String {
        didSet { defaults.set(dailyChallengeDay, forKey: Keys.dailyChallengeDay) }
    }

    @Published var dailyChallengeCompleted: Bool {
        didSet { defaults.set(dailyChallengeCompleted, forKey: Keys.dailyChallengeCompleted) }
    }

    @Published var totalDailyChallengesCompleted: Int {
        didSet { defaults.set(totalDailyChallengesCompleted, forKey: Keys.totalDailyChallengesCompleted) }
    }

    @Published var lastPlayDay: String {
        didSet { defaults.set(lastPlayDay, forKey: Keys.lastPlayDay) }
    }

    @Published var playStreakDays: Int {
        didSet { defaults.set(playStreakDays, forKey: Keys.playStreakDays) }
    }

    @Published var activitySessions: [String: Int] {
        didSet { saveStringIntMap(activitySessions, forKey: Keys.activitySessions) }
    }

    @Published var activityAccuracySum: [String: Double] {
        didSet { saveStringDoubleMap(activityAccuracySum, forKey: Keys.activityAccuracySum) }
    }

    @Published var completedTutorials: [String] {
        didSet { defaults.set(completedTutorials, forKey: Keys.completedTutorials) }
    }

    @Published var selectedThemeRaw: String {
        didSet { defaults.set(selectedThemeRaw, forKey: Keys.selectedTheme) }
    }

    @Published var expertUnlockedActivities: [String] {
        didSet { defaults.set(expertUnlockedActivities, forKey: Keys.expertUnlockedActivities) }
    }

    @Published var speedRunBests: [String: Int] {
        didSet { saveStringIntMap(speedRunBests, forKey: Keys.speedRunBests) }
    }

    @Published var bestComboOverall: Int {
        didSet { defaults.set(bestComboOverall, forKey: Keys.bestComboOverall) }
    }

    @Published var playDaysLog: [String] {
        didSet { defaults.set(playDaysLog, forKey: Keys.playDaysLog) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        streakCount = defaults.integer(forKey: Keys.streakCount)
        dailyChallengeDay = defaults.string(forKey: Keys.dailyChallengeDay) ?? ""
        dailyChallengeCompleted = defaults.bool(forKey: Keys.dailyChallengeCompleted)
        totalDailyChallengesCompleted = defaults.integer(forKey: Keys.totalDailyChallengesCompleted)
        lastPlayDay = defaults.string(forKey: Keys.lastPlayDay) ?? ""
        playStreakDays = defaults.integer(forKey: Keys.playStreakDays)
        selectedThemeRaw = defaults.string(forKey: Keys.selectedTheme) ?? AppTheme.classic.rawValue
        expertUnlockedActivities = defaults.stringArray(forKey: Keys.expertUnlockedActivities) ?? []
        bestComboOverall = defaults.integer(forKey: Keys.bestComboOverall)
        completedTutorials = defaults.stringArray(forKey: Keys.completedTutorials) ?? []
        playDaysLog = defaults.stringArray(forKey: Keys.playDaysLog) ?? []
        starsPerActivity = Self.loadDictionary(forKey: Keys.starsPerActivity, defaults: defaults)
        unlockedLevels = Self.loadUnlockedLevels(forKey: Keys.unlockedLevels, defaults: defaults)
        personalBests = Self.loadPersonalBests(forKey: Keys.personalBests, defaults: defaults)
        activitySessions = Self.loadStringIntMap(forKey: Keys.activitySessions, defaults: defaults)
        activityAccuracySum = Self.loadStringDoubleMap(forKey: Keys.activityAccuracySum, defaults: defaults)
        speedRunBests = Self.loadStringIntMap(forKey: Keys.speedRunBests, defaults: defaults)
        refreshDailyChallengeState()
    }

    var bestSingleLevelStars: Int {
        starsPerActivity.values.flatMap { $0.values }.flatMap { $0 }.max() ?? 0
    }

    var maxPerfectLevelsInOneActivity: Int {
        ActivityCatalog.all.map { activity in
            Difficulty.standardCases.map { difficulty in
                starsForActivity(activity.id, difficulty: difficulty.storageKey).filter { $0 == 3 }.count
            }.max() ?? 0
        }.max() ?? 0
    }

    var hasAnyThreeStarLevel: Bool {
        bestSingleLevelStars >= 3
    }

    var hasFullActivityThreeStars: Bool {
        ActivityCatalog.all.contains { activity in
            Difficulty.allCases.contains { difficulty in
                let stars = starsForActivity(activity.id, difficulty: difficulty.storageKey)
                return stars.count >= 5 && stars.prefix(5).allSatisfy { $0 == 3 }
            }
        }
    }

    func stars(for activityId: String, difficulty: String, level: Int) -> Int {
        guard level >= 0,
              let difficultyMap = starsPerActivity[activityId],
              let levels = difficultyMap[difficulty],
              level < levels.count else { return 0 }
        return levels[level]
    }

    func starsForActivity(_ activityId: String, difficulty: String) -> [Int] {
        starsPerActivity[activityId]?[difficulty] ?? Array(repeating: 0, count: 5)
    }

    func totalStars(for activityId: String) -> Int {
        starsForActivity(activityId, difficulty: Difficulty.easy.storageKey).reduce(0, +)
            + starsForActivity(activityId, difficulty: Difficulty.normal.storageKey).reduce(0, +)
            + starsForActivity(activityId, difficulty: Difficulty.hard.storageKey).reduce(0, +)
            + starsForActivity(activityId, difficulty: Difficulty.expert.storageKey).reduce(0, +)
    }

    func highestUnlockedLevel(activityId: String, difficulty: String) -> Int {
        unlockedLevels[activityId]?[difficulty] ?? 0
    }

    func isLevelUnlocked(activityId: String, difficulty: String, level: Int) -> Bool {
        if level == 0 { return true }
        return level <= highestUnlockedLevel(activityId: activityId, difficulty: difficulty)
    }

    func isExpertUnlocked(for activityId: String) -> Bool {
        expertUnlockedActivities.contains(activityId)
    }

    func hasCompletedTutorial(for activityId: String) -> Bool {
        completedTutorials.contains(activityId)
    }

    func markTutorialCompleted(for activityId: String) {
        guard !completedTutorials.contains(activityId) else { return }
        completedTutorials.append(activityId)
    }

    func personalBest(for activityId: String, difficulty: Difficulty, level: Int) -> PersonalBestRecord? {
        personalBests[LevelKey.make(activityId: activityId, difficulty: difficulty, level: level)]
    }

    func activityBreakdown() -> [ActivityBreakdownStat] {
        ActivityCatalog.all.map { activity in
            let sessions = activitySessions[activity.id] ?? 0
            let accuracy = sessions > 0 ? (activityAccuracySum[activity.id] ?? 0) / Double(sessions) : 0
            return ActivityBreakdownStat(
                id: activity.id,
                title: activity.title,
                sessions: sessions,
                averageAccuracy: accuracy,
                totalStars: totalStars(for: activity.id)
            )
        }
    }

    func isDailyChallengeAvailableToday() -> Bool {
        let today = DailyChallengeGenerator.challenge().dayToken
        refreshDailyChallengeState()
        return dailyChallengeDay == today && !dailyChallengeCompleted
    }

    func recordLevelResult(
        activityId: String,
        difficulty: String,
        level: Int,
        stars earned: Int,
        playTimeSeconds: Int,
        accuracy: Double,
        combo: Int,
        mode: GameMode
    ) {
        registerPlayDay()
        updateComboRecord(combo)

        if mode != .practice {
            activitySessions[activityId, default: 0] += 1
            activityAccuracySum[activityId, default: 0] += accuracy
        }

        updatePersonalBest(
            activityId: activityId,
            difficulty: difficulty,
            level: level,
            accuracy: accuracy,
            playTimeSeconds: playTimeSeconds,
            combo: combo
        )

        guard mode.awardsStars else { return }

        var activityStars = starsPerActivity[activityId] ?? [:]
        var levelStars = activityStars[difficulty] ?? Array(repeating: 0, count: 5)
        while levelStars.count < 5 { levelStars.append(0) }
        let previous = levelStars[level]
        var finalStars = max(previous, earned)

        if mode == .dailyChallenge, earned >= 1 {
            finalStars = max(finalStars, min(3, earned + 1))
        }

        levelStars[level] = finalStars
        activityStars[difficulty] = levelStars
        starsPerActivity[activityId] = activityStars

        if finalStars >= 1 {
            var unlocked = unlockedLevels[activityId] ?? [:]
            let current = unlocked[difficulty] ?? 0
            if level + 1 < 5 {
                unlocked[difficulty] = max(current, level + 1)
            } else {
                unlocked[difficulty] = max(current, level)
            }
            unlockedLevels[activityId] = unlocked
        }

        let starDelta = max(0, finalStars - previous)
        totalStarsEarned += starDelta
        totalActivitiesPlayed += 1
        totalPlayTimeSeconds += playTimeSeconds

        evaluateExpertUnlock(for: activityId)

        if mode == .dailyChallenge, earned >= 1 {
            completeDailyChallengeIfNeeded()
        }
    }

    func recordSpeedRun(activityId: String, totalSeconds: Int, completed: Bool) {
        registerPlayDay()
        guard completed else { return }
        let current = speedRunBests[activityId] ?? Int.max
        if totalSeconds < current {
            speedRunBests[activityId] = totalSeconds
        }
    }

    func completeDailyChallengeIfNeeded() {
        let today = DailyChallengeGenerator.challenge().dayToken
        guard dailyChallengeDay == today, !dailyChallengeCompleted else { return }
        dailyChallengeCompleted = true
        totalDailyChallengesCompleted += 1
        totalStarsEarned += 1
    }

    func resetAllProgress() {
        hasSeenOnboarding = false
        totalActivitiesPlayed = 0
        totalStarsEarned = 0
        totalPlayTimeSeconds = 0
        starsPerActivity = [:]
        unlockedLevels = [:]
        streakCount = 0
        personalBests = [:]
        dailyChallengeDay = ""
        dailyChallengeCompleted = false
        totalDailyChallengesCompleted = 0
        lastPlayDay = ""
        playStreakDays = 0
        activitySessions = [:]
        activityAccuracySum = [:]
        completedTutorials = []
        selectedThemeRaw = AppTheme.classic.rawValue
        expertUnlockedActivities = []
        speedRunBests = [:]
        bestComboOverall = 0
        playDaysLog = []

        let keys = [
            Keys.hasSeenOnboarding, Keys.totalActivitiesPlayed, Keys.totalStarsEarned, Keys.totalPlayTimeSeconds,
            Keys.starsPerActivity, Keys.unlockedLevels, Keys.streakCount, Keys.personalBests, Keys.dailyChallengeDay,
            Keys.dailyChallengeCompleted, Keys.totalDailyChallengesCompleted, Keys.lastPlayDay, Keys.playStreakDays,
            Keys.activitySessions, Keys.activityAccuracySum, Keys.completedTutorials, Keys.selectedTheme,
            Keys.expertUnlockedActivities, Keys.speedRunBests, Keys.bestComboOverall, Keys.playDaysLog
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        refreshDailyChallengeState()
        NotificationCenter.default.post(name: .progressReset, object: nil)
    }

    func newlyUnlockedAchievements(before snapshot: AchievementSnapshot) -> [AchievementDefinition] {
        AchievementCatalog.all.filter { achievement in
            !snapshot.unlockedIDs.contains(achievement.id) && achievement.isUnlocked(self)
        }
    }

    func achievementSnapshot() -> AchievementSnapshot {
        AchievementSnapshot(unlockedIDs: Set(
            AchievementCatalog.all.filter { $0.isUnlocked(self) }.map(\.id)
        ))
    }

    static func formattedPlayTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    static func dayToken(for date: Date = Date()) -> String {
        let calendar = Calendar.current
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    func recentPlayDayTokens(limit: Int = 14) -> [String] {
        let calendar = Calendar.current
        return (0..<limit).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            return Self.dayToken(for: date)
        }
    }

    func playedOnDay(_ token: String) -> Bool {
        playDaysLog.contains(token)
    }

    private func refreshDailyChallengeState() {
        let today = DailyChallengeGenerator.challenge().dayToken
        if dailyChallengeDay != today {
            dailyChallengeDay = today
            dailyChallengeCompleted = false
        }
    }

    private func registerPlayDay() {
        let today = Self.dayToken()
        if !playDaysLog.contains(today) {
            playDaysLog.append(today)
        }

        if lastPlayDay.isEmpty {
            playStreakDays = max(playStreakDays, 1)
        } else if lastPlayDay == today {
            // same day
        } else {
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let last = formatter.date(from: lastPlayDay),
               let diff = calendar.dateComponents([.day], from: last, to: Date()).day {
                if diff == 1 {
                    playStreakDays += 1
                } else if diff > 1 {
                    playStreakDays = 1
                }
            } else {
                playStreakDays = 1
            }
        }
        lastPlayDay = today
        streakCount = playStreakDays
    }

    private func updateComboRecord(_ combo: Int) {
        if combo > bestComboOverall {
            bestComboOverall = combo
        }
    }

    private func updatePersonalBest(
        activityId: String,
        difficulty: String,
        level: Int,
        accuracy: Double,
        playTimeSeconds: Int,
        combo: Int
    ) {
        let key = LevelKey.make(activityId: activityId, difficulty: difficulty, level: level)
        var best = personalBests[key] ?? PersonalBestRecord(bestAccuracy: 0, bestTimeSeconds: Int.max, bestCombo: 0)
        if accuracy > best.bestAccuracy { best.bestAccuracy = accuracy }
        if playTimeSeconds > 0, playTimeSeconds < best.bestTimeSeconds { best.bestTimeSeconds = playTimeSeconds }
        if combo > best.bestCombo { best.bestCombo = combo }
        if best.bestTimeSeconds == Int.max { best.bestTimeSeconds = max(playTimeSeconds, 0) }
        personalBests[key] = best
    }

    private func evaluateExpertUnlock(for activityId: String) {
        let hardStars = starsForActivity(activityId, difficulty: Difficulty.hard.storageKey)
        guard hardStars.count >= 5, hardStars.prefix(5).allSatisfy({ $0 >= 3 }) else { return }
        if !expertUnlockedActivities.contains(activityId) {
            expertUnlockedActivities.append(activityId)
        }
    }

    private static func loadDictionary(
        forKey key: String,
        defaults: UserDefaults
    ) -> [String: [String: [Int]]] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: [String: [Int]]].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveDictionary(_ value: [String: [String: [Int]]], forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadUnlockedLevels(
        forKey key: String,
        defaults: UserDefaults
    ) -> [String: [String: Int]] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: [String: Int]].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveUnlockedLevels(_ value: [String: [String: Int]], forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadPersonalBests(
        forKey key: String,
        defaults: UserDefaults
    ) -> [String: PersonalBestRecord] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: PersonalBestRecord].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func savePersonalBests(_ value: [String: PersonalBestRecord], forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadStringIntMap(forKey key: String, defaults: UserDefaults) -> [String: Int] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveStringIntMap(_ value: [String: Int], forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadStringDoubleMap(forKey key: String, defaults: UserDefaults) -> [String: Double] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Double].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveStringDoubleMap(_ value: [String: Double], forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }
}

struct AchievementSnapshot {
    let unlockedIDs: Set<String>
}
