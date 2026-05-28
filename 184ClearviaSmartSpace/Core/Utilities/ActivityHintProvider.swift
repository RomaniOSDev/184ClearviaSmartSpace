import Foundation

enum ActivityHintProvider {
    static func hint(activityId: String, mode: GameMode) -> String {
        if mode == .endless {
            return "Survive as many waves as you can. Each win raises the track intensity."
        }
        if mode == .weeklyEvent {
            return "Weekly Spotlight grants bonus stars on your first clear this week."
        }
        if mode == .customPattern {
            return "Replay the pattern you built in the Pattern Studio."
        }
        if mode == .duel {
            return "Take turns with a friend. Highest streak on the pattern wins the duel."
        }

        switch activityId {
        case "harmony_pulse":
            return "Tap when the ring closes on a note. Watch for the NOW! window."
        case "melody_glide":
            return "Drag each note to the lane that matches its color."
        case "melody_hold":
            return "Press and hold, then release when the timing bar fills."
        case "tap_sequence":
            return "Memorize the flashing notes, then tap them in the same order."
        default:
            return "Follow the on-screen rhythm cues for a perfect run."
        }
    }

    static func tutorialSteps(activityId: String) -> [(title: String, body: String, symbol: String)] {
        switch activityId {
        case "harmony_pulse":
            return [
                ("Watch the Pulse", "A ring shrinks toward the highlighted note.", "circle.circle"),
                ("Tap on Beat", "Press when the ring closes and you see NOW!", "hand.tap.fill"),
                ("Build a Streak", "Land perfect taps in a row to clear the track.", "flame.fill")
            ]
        case "melody_glide":
            return [
                ("Match Colors", "Each note matches one colored lane.", "paintpalette.fill"),
                ("Drag to Lane", "Drop the note onto its matching path.", "arrow.down.circle.fill"),
                ("Clear the Track", "Guide every note to the finish line.", "arrow.right.circle.fill")
            ]
        case "melody_hold":
            return [
                ("Hold the Note", "Press and hold falling notes.", "hand.point.up.left.fill"),
                ("Release on Time", "Let go when the bar fills for your color.", "timer"),
                ("Land Accurately", "Complete enough holds to finish the song.", "checkmark.circle.fill")
            ]
        case "tap_sequence":
            return [
                ("Watch the Pattern", "Notes flash in order — memorize them.", "eye.fill"),
                ("Repeat It", "Tap the same notes in the same order.", "list.number"),
                ("Chain Combos", "Longer patterns mean bigger combos.", "bolt.fill")
            ]
        default:
            return [
                ("Learn", "Read the hint bar during play.", "lightbulb.fill"),
                ("Practice", "Use Practice Mode to experiment.", "figure.walk"),
                ("Master", "Earn three stars on every track.", "star.fill")
            ]
        }
    }
}
