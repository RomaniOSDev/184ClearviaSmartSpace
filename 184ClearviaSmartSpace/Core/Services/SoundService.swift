import AudioToolbox

enum SoundService {
    static func playSuccess() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playFail() {
        AudioServicesPlaySystemSound(1521)
    }
}
