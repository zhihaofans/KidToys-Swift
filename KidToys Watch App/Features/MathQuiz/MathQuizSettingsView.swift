//
//  MathQuizSettingsView.swift
//  KidToys Watch App
//
//  家长设置页（加减法页左滑过来）：打开/关闭加法、减法。
//
//  两个都关掉就没有题可出了，所以剩下最后一个时会把它锁住不让关。
//  配色沿用随机数字设置页那种安静的深色，跟小孩玩的那页区分开。
//

import SwiftUI

struct MathQuizSettingsView: View {
    @AppStorage(MathQuizSettings.plusKey) private var allowPlus = MathQuizSettings.plusDefault
    @AppStorage(MathQuizSettings.minusKey) private var allowMinus = MathQuizSettings.minusDefault

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.17, green: 0.19, blue: 0.33), .black],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                Text("出题类型")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 2)

                toggleRow("加法",
                          symbol: "plus",
                          isOn: $allowPlus,
                          tint: .orange,
                          locked: allowPlus && !allowMinus)

                toggleRow("减法",
                          symbol: "minus",
                          isOn: $allowMinus,
                          tint: .teal,
                          locked: allowMinus && !allowPlus)

                // 只在锁住时出现，告诉家长为什么这个开关点不动
                if allowPlus != allowMinus {
                    Text("至少留一种")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.tertiary)
                        .transition(.opacity)
                }
            }
            .foregroundStyle(.white)
            .animation(.easeInOut(duration: 0.15), value: allowPlus == allowMinus)
        }
        // 兜底：万一两个都被关掉，把刚关的那个弹回来，不让出现「没题可出」的状态
        .onChange(of: allowPlus) { _, newValue in
            if !newValue && !allowMinus { allowPlus = true }
        }
        .onChange(of: allowMinus) { _, newValue in
            if !newValue && !allowPlus { allowMinus = true }
        }
    }

    private func toggleRow(_ title: String,
                           symbol: String,
                           isOn: Binding<Bool>,
                           tint: Color,
                           locked: Bool) -> some View {
        let on = isOn.wrappedValue

        return HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(on ? tint : Color.secondary)
                .frame(width: 16)

            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer(minLength: 2)

            Toggle(title, isOn: isOn)
                .labelsHidden()
                .tint(tint)
        }
        .padding(.horizontal, 10)
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white.opacity(on ? 0.15 : 0.06))
        )
        // 只剩这一种题型时锁住开关，两个都关就没题可出了
        .opacity(locked ? 0.55 : 1)
        .disabled(locked)
    }
}

#Preview {
    MathQuizSettingsView()
}
