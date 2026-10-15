//
//  RandomLetterView.swift
//  KidToys Watch App
//
//  随机大写字母 A-Z。和随机数字、随机颜色一样：整屏任意位置点一下换一个字母。
//

import SwiftUI

struct RandomLetterView: View {
    static let allLetters: [String] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map(String.init)

    @State private var letter = RandomLetterView.allLetters.randomElement() ?? "A"
    /// 每次换字母自增，用来触发触感
    @State private var tick = 0

    var body: some View {
        ZStack {
            LinearGradient(colors: [.green, .blue],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text(letter)
                    .font(.system(size: 110, weight: .heavy, design: .rounded))
                    .contentTransition(.opacity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .opacity(0.5)
                    .padding(.top, 4)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
        }
        // 整屏可点，孩子不用瞄准
        .contentShape(Rectangle())
        .onTapGesture { next() }
        .animation(.snappy(duration: 0.18), value: letter)
        .sensoryFeedback(.impact(weight: .light), trigger: tick)
    }

    private func next() {
        // 从"除当前字母以外"里挑，避免连着两次同一个字母，孩子会以为点了没反应
        guard let picked = Self.allLetters.filter({ $0 != letter }).randomElement() else { return }
        letter = picked
        tick += 1
    }
}

#Preview {
    RandomLetterView()
}
