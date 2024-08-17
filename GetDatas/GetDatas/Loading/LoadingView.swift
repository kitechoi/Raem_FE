import SwiftUI

struct LoadingView: View {
    @State private var isActive = false
    
    var body: some View {
        VStack {
            if isActive {
                CarouselView()
            } else {
                VStack {
                    Spacer()
                    Text("raem")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.deepNavy)
                    Spacer()
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    // 2초 후에 CarouselView로 이동
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

