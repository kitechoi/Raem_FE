import SwiftUI

struct BedTimeAlarmView: View {
    @State private var selectedTab: Tab = .bedtime

    enum Tab {
        case bedtime
        case alarm
    }

    var body: some View {
        VStack(spacing: 20) {
            // 상단 Back 버튼 및 탭 선택
            HStack {
                Button(action: {
                    // 뒤로가기 액션
                }) {
                    Image("backbutton")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("취침 시간")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(selectedTab == .bedtime ? .black : .gray)
                    .onTapGesture {
                        selectedTab = .bedtime
                    }
                Spacer()
                Text("알람")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(selectedTab == .alarm ? .black : .gray)
                    .onTapGesture {
                        selectedTab = .alarm
                    }
                Spacer()
                // 빈 공간 확보
                Image(systemName: "chevron.left")
                    .foregroundColor(.clear)
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.top, 10) // 상단에 약간의 여백 추가

            // 선택된 탭에 따라 다른 뷰 표시
            if selectedTab == .bedtime {
                BedtimeView()
            } else {
                AlarmView()
            }

            Spacer(minLength: 20) // 아래쪽 여백 조정

            // 하단 탭 바
            CustomTabBar(selectedTab: .constant(.home))
                .padding(.bottom, 10) // 탭 바가 하단에 붙지 않도록 여백 추가
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

struct BedtimeView: View {
    @State private var selectedHour = 3
    @State private var selectedMinute = 50
    @State private var isAM = true
    @State private var receiveAlarm = true

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Picker(selection: $selectedHour, label: Text("")) {
                    ForEach(1..<13) { hour in
                        Text(String(format: "%02d", hour)).tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)

                Picker(selection: $selectedMinute, label: Text("")) {
                    ForEach(0..<60) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)

                Picker(selection: $isAM, label: Text("")) {
                    Text("AM").tag(true)
                    Text("PM").tag(false)
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)
            }
            .padding(.horizontal, 16)

            Text("수면 시간 목표는 7시간 30분 입니다.\n취침시간 및 알람시간에 근거함")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Toggle(isOn: $receiveAlarm) {
                Text("취침 시간 알림 받기")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5))
            )
            .padding(.horizontal, 16)
        }
        .padding(.top, 20) // 상단 여백 추가
    }
}

struct AlarmView: View {
    @State private var selectedHour = 3
    @State private var selectedMinute = 50
    @State private var isAM = true

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Picker(selection: $selectedHour, label: Text("")) {
                    ForEach(1..<13) { hour in
                        Text(String(format: "%02d", hour)).tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)

                Picker(selection: $selectedMinute, label: Text("")) {
                    ForEach(0..<60) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)

                Picker(selection: $isAM, label: Text("")) {
                    Text("AM").tag(true)
                    Text("PM").tag(false)
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)
            }
            .padding(.horizontal, 16)

            Text("수면 시간 목표는 7시간 30분 입니다.\n취침시간 및 알람시간에 근거함")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            VStack(spacing: 20) {
                HStack {
                    Text("스마트 알람")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: .constant(true))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                .padding(.horizontal, 16)

                HStack {
                    Text("기상 시간대")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Text("30분")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                .padding(.horizontal, 16)

                HStack {
                    Text("다시 알림")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Text("10분")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                .padding(.horizontal, 16)

                HStack {
                    Text("알람 벨소리")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Text("상쾌한 아침")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 20) // 상단 여백 추가
    }
}

struct BedTimeAlarmView_Previews: PreviewProvider {
    static var previews: some View {
        BedTimeAlarmView()
    }
}

