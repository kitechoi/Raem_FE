import SwiftUI
import Charts

struct Score: Identifiable {
    let id = UUID()
    let label: String
    let avgScore: Double
}


struct WeeklyView: View {
    let scores: [Score] = [
        .init(label: "Mon", avgScore: 3.5),
        .init(label: "Tue", avgScore: 2),
        .init(label: "Wed", avgScore: 4),
        .init(label: "Thu", avgScore: 1.5),
        .init(label: "Fri", avgScore: 0),
        .init(label: "Sat", avgScore: 3),
        .init(label: "Sun", avgScore: 3)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            VStack(spacing: 20) {
                HStack {
                    Text("수면 별점")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                Chart {
                    ForEach(scores) { score in
                        BarMark(
                            x: .value("weekDay", score.label),
                            y: .value("score", score.avgScore),
                            width: 20
                        )
                        .foregroundStyle(Color.deepNavy)
                        
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .stride(by: 1)) { value in
                        AxisGridLine()
                            .foregroundStyle(Color.gray)
                        AxisTick()
                            .foregroundStyle(Color.gray)
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                            .foregroundStyle(Color.gray)
                        AxisTick()
                            .foregroundStyle(Color.gray)
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartYScale(domain: 0...5)
                .frame(height: 170)
            }
            .padding(.vertical, 8)
            
            VStack(spacing: 20) {
                HStack {
                    Text("이번 주 평균 수면 깊이")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                
                VStack(alignment: .leading){
                    HStack{
                        Spacer()
                        VStack(alignment: .leading) {
                            HStack(spacing: 45) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 16) {
                                        Image("moon")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        
                                        VStack(alignment: .leading, spacing: 4){
                                            Text("6시간 52분")
                                                .font(Font.system(size: 18, weight: .bold))
                                                .foregroundColor(.black)
                                            Text("Time in sleep")
                                                .font(Font.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.trailing, 10)

                                VStack(spacing: 4) {
                                    HStack(spacing: 16) {
                                        Image("zzz")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        VStack(alignment: .leading, spacing: 4){
                                            Text("25분")
                                                .font(Font.system(size: 18, weight: .bold))
                                                .foregroundColor(.black)
                                            Text("Fell asleep")
                                                .font(Font.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            
                            HStack(spacing: 45) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 16) {
                                        Image("watch")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        VStack(alignment: .leading, spacing:4) {
                                            Text("7시간 23분")
                                                .font(Font.system(size: 18, weight: .bold))
                                                .foregroundColor(.black)
                                            Text("Went to bed")
                                                .font(Font.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.trailing, 10)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 16) {
                                        Image("sun")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("07시 12분")
                                                .font(Font.system(size: 18, weight: .bold))
                                                .foregroundColor(.black)
                                            Text("Wake up time")
                                                .font(Font.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 25)
                        }
                        Spacer()
                    }
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
    }
}

struct WeeklyView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyView()
    }
}
