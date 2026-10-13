//
//  RandomNumberView.swift
//  KidToys Watch App
//
//  随机数字 1-100。给 3 岁小孩用，所以不设小按钮 —— 整屏任意位置点一下就是"摇一次"。
//

import SwiftUI

struct RandomNumberView: View {
    /// 当前显示的数字
    @State private var number = Int.random(in: 1...100)
    /// 正在滚动：挡掉连点，避免叠加出好几轮动画
    @State private var isRolling = false
    /// 落定后自增一次，用来触发一次明确的"停下来了"触感
    @State private var settleTick = 0

    var body: some View {
        ZStack {
            // containerBackground(for: .navigation) 在 watchOS 上没生效（背景仍是黑的），直接用整屏渐变
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
    }

    private func roll() {
        guard !isRolling else { return }
        isRolling = true

        Task {
            // 先快速跳一阵，最后再定下来，孩子能看清"在变"
            for _ in 0..<14 {
                number = Int.random(in: 1...100)
                try? await Task.sleep(for: .milliseconds(55))
            }
            number = Int.random(in: 1...100)
            isRolling = false
            settleTick += 1
        }
    }
}

#Preview {
    RandomNumberView()
}
