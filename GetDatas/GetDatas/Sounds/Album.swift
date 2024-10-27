import SwiftUI

struct Album: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let audioFileName: String 
}

