import SwiftUI
import Charts

struct AnnuallyView: View {
    let scores: [Score] = [
        .init(label: "1월", avgScore: 3.5),
        .init(label: "2월", avgScore: 4),
        .init(label: "3월", avgScore: 3.3),
        .init(label: "4월", avgScore: 1.25),
        .init(label: "5월", avgScore: 1),
        .init(label: "6월", avgScore: 2),
        .init(label: "7월", avgScore: 0),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            VStack(spacing: 20) {
                HStack {
                    Text("수면 별점")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                }
                
                Chart {
                    ForEach(scores) { score in
                        BarMark(
                            x: .value("month", score.label),
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
                    Text("이번 달 평균 수면 깊이")
                        .font(.system(size: 24, weight: .bold))
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
            
            VStack(spacing: 20) {
                HStack {
                    Text("2024 수면 레포트")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12){
                    HStack {
                        Text("전체 수면 패턴")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                    
                    Text("1월과 3월에 수면 시간과 질의 변동이 있었으나 2월에 안정화됨\n총 수면 시간과 수면의 질이 점차 개선되는 추세")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.gray)
                    
                    HStack {
                        Text("개선 사항")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                    .padding(.top, 16)
                    
                    Text("스마트폰 사용 줄이기, 카페인 섭취 조절 성공\n매일 같은 시간에 잠들기, 수면 환경 지속적 개선")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.gray)
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

struct AnnuallyView_Previews: PreviewProvider {
    static var previews: some View {
        AnnuallyView()
    }
}
