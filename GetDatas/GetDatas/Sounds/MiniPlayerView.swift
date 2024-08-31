import SwiftUI
import AVFoundation

struct MiniPlayerView: View {
    var album: Album
    @Binding var isPopupVisible: Bool
    
    @State private var isPlaying: Bool = false
    @State private var player: AVAudioPlayer?
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 60

    var body: some View {
        VStack {
            HStack {
                Image(album.imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
                
                VStack(alignment: .leading) {
                    Text(album.title)
                        .font(.headline)
                    Text("\(album.songs) songs  •  \(album.duration)min")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    togglePlayPause()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    isPopupVisible = false
                    player?.stop() // 팝업이 닫힐 때 음악도 멈추게 합니다.
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding([.leading, .trailing, .bottom])
        }
        .onAppear {
            setupPlayer()
        }
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
            print("Player initialized successfully")
        } catch {
            print("Failed to initialize player: \(error)")
            return
        }
    }

    func togglePlayPause() {
        guard let player = player else { return }

        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
}

