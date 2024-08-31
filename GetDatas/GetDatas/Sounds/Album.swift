import SwiftUI

struct Album: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let songs: Int
    let duration: Int
    let audioFileName: String 
}

