import SwiftUI

struct AlbumView: View {
    var album: Album
    var onPlayButtonTapped: () -> Void
    
    var body: some View {
        VStack {
            Image(album.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(10)
                .overlay(
                    Button(action: {
                        onPlayButtonTapped()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .opacity(0.8)
                    }
                    .padding()
                    , alignment: .center
                )
            
            Text(album.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.deepNavy)
                .padding(.top, 5)
        }
    }
}

