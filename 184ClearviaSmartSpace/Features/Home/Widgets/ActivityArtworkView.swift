import SwiftUI

enum ActivityArtworkStyle {
    case harmonyPulse
    case melodyGlide
    case melodyHold
    case tapSequence
    case hero

    init(activityId: String) {
        switch activityId {
        case "harmony_pulse": self = .harmonyPulse
        case "melody_glide": self = .melodyGlide
        case "melody_hold": self = .melodyHold
        case "tap_sequence": self = .tapSequence
        default: self = .hero
        }
    }
}

struct ActivityArtworkView: View {
    let style: ActivityArtworkStyle
    var animate: Bool = true

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 12.0)) { timeline in
            Canvas { context, size in
                let t = animate ? timeline.date.timeIntervalSinceReferenceDate : 0
                switch style {
                case .harmonyPulse: drawHarmonyPulse(context: context, size: size, t: t)
                case .melodyGlide: drawMelodyGlide(context: context, size: size, t: t)
                case .melodyHold: drawMelodyHold(context: context, size: size, t: t)
                case .tapSequence: drawTapSequence(context: context, size: size, t: t)
                case .hero: drawHero(context: context, size: size, t: t)
                }
            }
            .drawingGroup(opaque: false)
        }
        .background(
            LinearGradient(
                colors: [Color("AppBackground").opacity(0.3), Color("AppPrimary").opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipped()
    }

    private func drawHero(context: GraphicsContext, size: CGSize, t: TimeInterval) {
        let w = size.width
        let h = size.height
        for i in 0..<4 {
            let y = h * (0.35 + CGFloat(i) * 0.12)
            var wave = Path()
            wave.move(to: CGPoint(x: 0, y: y))
            for x in stride(from: 0.0, through: Double(w), by: 6) {
                let offset = sin(x / 22 + t * 1.6 + Double(i)) * 8
                wave.addLine(to: CGPoint(x: x, y: y + offset))
            }
            context.stroke(wave, with: .color(Color("AppAccent").opacity(0.35 - Double(i) * 0.06)), lineWidth: 2)
        }
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 + t * 0.4
            let cx = w * 0.72 + cos(angle) * 28
            let cy = h * 0.42 + sin(angle) * 18
            let rect = CGRect(x: cx - 10, y: cy - 10, width: 20, height: 20)
            context.fill(Path(ellipseIn: rect), with: .color(Color("AppPrimary").opacity(0.75)))
        }
        let noteRect = CGRect(x: w * 0.18, y: h * 0.28, width: 44, height: 44)
        context.fill(Path(ellipseIn: noteRect), with: .color(Color("AppPrimary")))
        context.stroke(Path(ellipseIn: noteRect.insetBy(dx: -6, dy: -6)), with: .color(Color("AppAccent").opacity(0.7)), lineWidth: 2)
    }

    private func drawHarmonyPulse(context: GraphicsContext, size: CGSize, t: TimeInterval) {
        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.52)
        let pulse = 28 + sin(t * 2.2) * 10
        for ring in 0..<3 {
            let r = pulse + CGFloat(ring) * 22
            context.stroke(
                Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)),
                with: .color(Color("AppAccent").opacity(0.5 - Double(ring) * 0.12)),
                lineWidth: 2
            )
        }
        for i in 0..<5 {
            let angle = Double(i) * 2 * .pi / 5 - .pi / 2
            let x = center.x + cos(angle) * 52
            let y = center.y + sin(angle) * 40
            context.fill(Path(ellipseIn: CGRect(x: x - 12, y: y - 12, width: 24, height: 24)), with: .color(Color("AppPrimary")))
        }
    }

    private func drawMelodyGlide(context: GraphicsContext, size: CGSize, t: TimeInterval) {
        for lane in 0..<4 {
            let y = size.height * (0.28 + CGFloat(lane) * 0.16)
            var path = Path()
            path.move(to: CGPoint(x: 12, y: y))
            path.addLine(to: CGPoint(x: size.width - 12, y: y))
            context.stroke(path, with: .color(Color("AppAccent").opacity(0.55)), lineWidth: 3)
        }
        let noteX = 24 + (sin(t * 1.8) * 0.5 + 0.5) * (size.width - 48)
        context.fill(
            Path(ellipseIn: CGRect(x: noteX - 14, y: size.height * 0.28 - 14, width: 28, height: 28)),
            with: .color(Color("AppPrimary"))
        )
    }

    private func drawMelodyHold(context: GraphicsContext, size: CGSize, t: TimeInterval) {
        for i in 0..<3 {
            let x = size.width * (0.25 + CGFloat(i) * 0.25)
            var path = Path()
            path.move(to: CGPoint(x: x, y: 16))
            path.addLine(to: CGPoint(x: x, y: size.height - 12))
            context.stroke(path, with: .color(Color("AppPrimary").opacity(0.45)), lineWidth: 5)
        }
        let hold = min(1.0, (sin(t * 1.5) * 0.5 + 0.5))
        let barRect = CGRect(x: size.width * 0.2, y: size.height - 28, width: size.width * 0.6 * hold, height: 8)
        context.fill(Path(roundedRect: barRect, cornerRadius: 4), with: .color(Color("AppAccent")))
        context.fill(
            Path(ellipseIn: CGRect(x: size.width * 0.45, y: 24, width: 26, height: 26)),
            with: .color(Color("AppPrimary"))
        )
    }

    private func drawTapSequence(context: GraphicsContext, size: CGSize, t: TimeInterval) {
        let letters = ["C", "D", "E", "F"]
        for (i, letter) in letters.enumerated() {
            let x = size.width * (0.18 + CGFloat(i) * 0.2)
            let active = Int(t * 2) % letters.count == i
            let rect = CGRect(x: x - 18, y: size.height * 0.38, width: 36, height: 36)
            context.fill(Path(ellipseIn: rect), with: .color(active ? Color("AppAccent") : Color("AppSurface")))
            context.draw(
                Text(letter).font(.headline.bold()).foregroundColor(Color("AppTextPrimary")),
                at: CGPoint(x: x, y: size.height * 0.38 + 18),
                anchor: .center
            )
        }
    }
}
