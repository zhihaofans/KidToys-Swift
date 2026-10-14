//
//  RandomNumberRollView.swift
//  KidToys Watch App
//
//  摇数字那一页。给 3 岁小孩用，所以不设小按钮 —— 整屏任意位置点一下就是"摇一次"。
//

import SwiftUI

struct RandomNumberRollView: View {
    // 家长在设置页改的上下限，存 UserDefaults，重启也记得
    @AppStorage(RandomRange.minKey) private var minValue = RandomRange.defaultMin
    @AppStorage(RandomRange.maxKey) private var maxValue = RandomRange.defaultMax

    /// 当前显示的数字。先用全局范围随机一个，onChange(initial:) 再按存储的范围兜底
    @State private var number = Int.random(in: RandomRange.lowerBound...RandomRange.upperBound)
    /// 正在滚动：挡掉连点，避免叠加出好几轮动画
    @State private var isRolling = false
    /// 落定后自增一次，用来触发一次明确的"停下来了"触感
    @State private var settleTick = 0

    /// 兜底：即使存储里的值被写坏成 min > max，也不会构造出非法区间而崩掉
    private var range: ClosedRange<Int> {
        let low = Swift.min(minValue, maxValue)
        let high = Swift.max(minValue, maxValue)
        return low...high
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange, .pink],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("\(number)")
                    .font(.system(size: 82, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .opacity(isRolling ? 0.1 : 0.5)
                    .padding(.top, 2)

                // 当前范围，让家长改完设置后一眼看到生效了
                Text("\(range.lowerBound) ~ \(range.upperBound)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .opacity(0.45)
                    .padding(.top, 6)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
        }
        // 整屏可点，孩子不用瞄准
        .contentShape(Rectangle())
        .onTapGesture { roll() }
        // 数字每跳一次震一下，滚动时像老虎机
        .sensoryFeedback(.impact(weight: .light), trigger: number)
        // 停下来再给一次明确的反馈
        .sensoryFeedback(.success, trigger: settleTick)
        .animation(.snappy(duration: 0.12), value: number)
        // initial: true 让首次进入也走一遍，把范围外的初始数字拉回来
        .onChange(of: range, initial: true) { _, newRange in
            if !newRange.contains(number) {
                number = newRange.randomElement() ?? newRange.lowerBound
            }
        }
    }

    private func roll() {
        guard !isRolling else { return }
        isRolling = true

        Task {
            // 先快速跳一阵，最后再定下来，孩子能看清"在变"
            for _ in 0..<14 {
                number = range.randomElement() ?? range.lowerBound
                try? await Task.sleep(for: .milliseconds(55))
            }
            number = range.randomElement() ?? range.lowerBound
            isRolling = false
            settleTick += 1
        }
    }
}

#Preview {
    RandomNumberRollView()
}
