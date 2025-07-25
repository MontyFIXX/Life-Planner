import SwiftUI

struct HeartProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.pink)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.largeTitle)
                .bold()
        }
        .padding()
    }
}
