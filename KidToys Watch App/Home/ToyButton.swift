//
//  ToyButton.swift
//  KidToys Watch App
//
//  首页大按钮：为低龄儿童设计 —— 整块可点、图标大、配色亮、高对比。
//

import SwiftUI

struct ToyButton: View {
    let feature: ToyFeature

    private let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

    var body: some View {
        VStack(spacing: 4) {
            iconView
                // 文字图标和 SF Symbol 的行高不一样，统一给个高度让各按钮的标签对齐
                .frame(height: 38)

            Text(feature.title)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(shape.fill(feature.tint.gradient))
        // 小朋友容易点偏，把整块矩形都算作命中区域
        .contentShape(shape)
    }

    @ViewBuilder
    private var iconView: some View {
        switch feature.icon {
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: 34, weight: .bold))
        case .text(let value):
            Text(value)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
        }
    }
}

#Preview {
    ToyButton(feature: .randomNumber)
        .padding()
}
