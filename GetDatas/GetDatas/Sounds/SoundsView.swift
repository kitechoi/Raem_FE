import SwiftUI

struct SoundsView: View {
    @State private var isPopupVisible: Bool = false
    @State private var selectedAlbum: Album? = nil

    var albums: [Album] = [
        Album(title: "동물의 숲", imageName: "image1", audioFileName: "1"),
        Album(title: "고요한 밤", imageName: "image2", audioFileName: "2"),
        Album(title: "평온의 속삭임", imageName: "image3", audioFileName: "3"),
        Album(title: "별빛의 꿈", imageName: "image4", audioFileName: "4"),
        Album(title: "잠의 멜로디", imageName: "image5", audioFileName: "5"),
        Album(title: "하늘의 자장가", imageName: "image6", audioFileName: "6")
    ]


    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Spacer()

                        Text("수면을 위한 음악")
                            .font(.title)
                            .bold()
                            .padding([.leading, .trailing], 16)
                            .padding(.top, 20)
                            .foregroundColor(.black)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(albums) { album in
                                NavigationLink(destination: MusicPlayerView(album: album)) {
                                    AlbumView(album: album) {
                                        self.selectedAlbum = album
                                        self.isPopupVisible = true
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.white)
                }

                Spacer()

                if isPopupVisible, let selectedAlbum = selectedAlbum {
                    MiniPlayerView(album: selectedAlbum, isPopupVisible: $isPopupVisible)
                        .transition(.move(edge: .bottom))
                        .animation(.spring())
                }
            }
            .background(Color.white)
        }
    }
}

struct SoundsView_Previews: PreviewProvider {
    static var previews: some View {
        SoundsView()
    }
}

