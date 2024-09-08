import SwiftUI
import AVFoundation

struct MusicPlayerView: View {
    var album: Album

    @State private var isPlaying: Bool = false
    @State private var player: AVAudioPlayer?
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 60

    var body: some View {
        VStack {
            Spacer().frame(height: 20)

            Text("수면을 위한 음악")
                .font(.title)
                .bold()
                .padding(.top, 20)

            Image(album.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .cornerRadius(10)
                .padding(.top, 20)

            Text(album.title)
                .font(.title2)
                .padding(.top, 10)

            Text("\(album.songs) songs    \(album.duration)min")
                .foregroundColor(.gray)
                .padding(.top, 5)

            Slider(value: $currentTime, in: 0...duration, onEditingChanged: { _ in
                seekToTime()
            })
            .padding(.top, 20)

            HStack {
                Text(formatTime(currentTime))
                Spacer()
                Text(formatTime(duration))
            }
            .padding(.horizontal, 40)

            HStack(spacing: 50) {
                Button(action: {
                    stopMusic()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }

                Button(action: {
                    playMusic()
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }

                Button(action: {
                    // 다음 트랙 기능 구현 (필요시 추가)
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            stopMusic()  // 뷰가 사라질 때 음악을 멈춤
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func setupPlayer() {
        // 오디오 세션 설정
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }

        guard let path = Bundle.main.path(forResource: album.audioFileName, ofType: "mp3") else {
            print("Audio file not found")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            duration = player?.duration ?? 60
            player?.prepareToPlay()
            player?.volume = 1.0  // 볼륨 설정
        } catch {
            print("Failed to initialize player: \(error)")
            return
        }

        // 타이머로 재생 시간을 업데이트
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let player = player {
                self.currentTime = player.currentTime
            }
        }
    }

    func playMusic() {
        guard let player = player else { return }

        if !player.isPlaying {
            player.play()
        }
    }

    func stopMusic() {
        guard let player = player else { return }
        player.stop()
        player.currentTime = 0
        currentTime = 0
        isPlaying = false
    }

    func seekToTime() {
        guard let player = player else { return }
        player.currentTime = currentTime
        if isPlaying {
            player.play()
        }
    }
}

