//
//  RandomNumberRangeSettingsView.swift
//  KidToys Watch App
//
//  家长设置页（随机数字页左滑过来）：调随机数的上下限。
//
//  用两个上下滚动的数字轮（和表盘上调时间一样），而不是 ± 按钮：
//  范围放宽到 -500 ~ 500 之后，靠加减点 1000 下根本没法用。
//  这一页是给家长用的，配色故意做得比摇数字页安静。
//

import SwiftUI

struct RandomNumberRangeSettingsView: View {
    @AppStorage(RandomRange.minKey) private var minValue = RandomRange.defaultMin
    @AppStorage(RandomRange.maxKey) private var maxValue = RandomRange.defaultMax

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.17, green: 0.19, blue: 0.33), .black],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("数字范围")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 2)

                HStack(spacing: 0) {
                    wheel(title: "最小", selection: $minValue)
                    wheel(title: "最大", selection: $maxValue)
                }
            }
            .foregroundStyle(.white)
        }
        // 上下限互相推着走，保证任何时候都是 最小 ≤ 最大
        .onChange(of: minValue) { _, newValue in
            if maxValue < newValue { maxValue = newValue }
        }
        .onChange(of: maxValue) { _, newValue in
            if minValue > newValue { minValue = newValue }
        }
    }

    /// 像时钟一样上下滚动的数字轮
    private func wheel(title: String, selection: Binding<Int>) -> some View {
        VStack(spacing: 0) {
            // .wheel 不显示标签，标题得自己加
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Picker(title, selection: selection) {
                ForEach(RandomRange.lowerBound...RandomRange.upperBound, id: \.self) { value in
                    Text("\(value)")
                        .monospacedDigit()
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            // 轮子默认高度会超出表盘，压到只露 3 行左右
            .frame(height: 104)
            .clipped()
        }
    }
}

#Preview {
    RandomNumberRangeSettingsView()
}
