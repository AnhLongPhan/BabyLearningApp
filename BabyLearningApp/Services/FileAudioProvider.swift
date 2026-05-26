import AVFoundation
import Foundation

final class FileAudioProvider: NSObject {
    private var audioPlayer: AVAudioPlayer?
    private var playbackContinuation: CheckedContinuation<Void, Never>?

    func play(url: URL) async {
        stop()

        await withCheckedContinuation { continuation in
            playbackContinuation = continuation
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                audioPlayer = player
                player.delegate = self
                player.prepareToPlay()
                player.play()
            } catch {
                finishPlayback()
            }
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        finishPlayback()
    }

    private func finishPlayback() {
        playbackContinuation?.resume()
        playbackContinuation = nil
    }
}

extension FileAudioProvider: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
        finishPlayback()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        audioPlayer = nil
        finishPlayback()
    }
}
