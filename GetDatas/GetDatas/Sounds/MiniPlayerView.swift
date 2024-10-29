import SwiftUI
import AVFoundation

struct MiniPlayerView: View {
    var album: Album
    @Binding var isPopupVisible: Bool
    
    @State private var player: AVAudioPlayer?
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 60
    
    @EnvironmentObject var bleManager: BLEManager

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
                }
                
                Spacer()
                
                Button(action: {
                    if bleManager.connectSuccess == false {
                        playMusic()
                    } else {
                        bleManager.turnOnAudio("\(album.audioFileName),40,music")
                    }
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 10)
                
                Button(action: {
                    isPopupVisible = false
                    if bleManager.connectSuccess == false {
                        player?.stop() // 팝업이 닫힐 때 음악도 멈추게 합니다.
                    } else {
                        bleManager.turnOffAudio("Off")
                    }
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
            if bleManager.connectSuccess == false {
                setupPlayer()
            }
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

    func playMusic() {
        guard let player = player else { return }

        if !player.isPlaying {
            player.play()
        }
    }
}

