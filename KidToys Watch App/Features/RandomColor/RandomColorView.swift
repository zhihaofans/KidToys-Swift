//
//  RandomColorView.swift
//  KidToys Watch App
//
//  随机颜色。和随机数字一样：整屏任意位置点一下换一个颜色。
//  这个是单页功能，不需要设置界面。
//

import SwiftUI

struct RandomColorView: View {
    @State private var current = ToyPalette.all.randomElement() ?? ToyPalette.all[0]
    /// 每次换色自增，用来触发触感
    @State private var tick = 0

    var body: some View {
        ZStack {
            current.color
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // 颜色名是给家长念给孩子听的，顺便让孩子建立"颜色—名字"的对应
                Text(current.name)
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .opacity(0.5)
            }
            .foregroundStyle(current.foreground)
            .padding(.horizontal, 8)
        }
        // 整屏可点，孩子不用瞄准
        .contentShape(Rectangle())
        .onTapGesture { next() }
        .animation(.snappy(duration: 0.18), value: current)
        .sensoryFeedback(.impact(weight: .light), trigger: tick)
    }

    private func next() {
        // 从"除当前色以外"里挑，避免连着两次同一个色，孩子会以为点了没反应
        guard let picked = ToyPalette.all.filter({ $0 != current }).randomElement() else { return }
        current = picked
        tick += 1
    }
}

#Preview {
    RandomColorView()
}
