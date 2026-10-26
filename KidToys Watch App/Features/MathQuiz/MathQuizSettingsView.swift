//
//  MathQuizSettingsView.swift
//  KidToys Watch App
//
//  家长设置页（加减法页左滑过来）：从左到右一根滑块选题型。
//
//  左边「加法」= 只出加法，中间「都出」= 加减都出，右边「减法」= 只出减法。
//  点一下能选，横着滑也能选 —— 滑块自己会滑过去。
//  配色沿用随机数字设置页那种安静的深色，跟小孩玩的那页区分开。
//

import SwiftUI

struct MathQuizSettingsView: View {
    // 默认值用折算结果，老数据（两个开关）没有新键时滑块也能停在对的位置
    @AppStorage(MathQuizSettings.modeKey)
    private var modeRaw = MathQuizSettings.currentMode().rawValue
    @Namespace private var pill

    private var mode: MathQuizMode {
        MathQuizMode(rawValue: modeRaw) ?? MathQuizSettings.defaultMode
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.17, green: 0.19, blue: 0.33), .black],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Text("出题类型")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)

                picker

                Text(mode.caption)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .contentTransition(.opacity)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
        }
    }

    // MARK: - 三档滑块

    private var picker: some View {
        HStack(spacing: 0) {
            ForEach(MathQuizMode.allCases) { item in
                Button {
                    select(item)
                } label: {
                    Text(item.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(mode == item ? Color.white : Color.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background {
                            // 滑块的底：选中哪档就挪到哪档，靠 matchedGeometryEffect 滑过去
                            if mode == item {
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .fill(item.tint.gradient)
                                    .matchedGeometryEffect(id: "pill", in: pill)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 42)
        .padding(3)
        .background(
            Capsule(style: .continuous)
                .fill(.white.opacity(0.10))
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.82), value: modeRaw)
        // 点还是点，滑是加在旁边的：手指横着划就把滑块挪一档，到头就不动
        .simultaneousGesture(
            DragGesture(minimumDistance: 15)
                .onEnded { value in
                    guard abs(value.translation.width) > 15 else { return }
                    select(mode.stepped(by: value.translation.width > 0 ? 1 : -1))
                }
        )
    }

    private func select(_ newMode: MathQuizMode) {
        guard newMode != mode else { return }
        modeRaw = newMode.rawValue
    }
}

private extension MathQuizMode {
    var tint: Color {
        switch self {
        case .plusOnly: return .orange
        case .both: return .purple
        case .minusOnly: return .teal
        }
    }
}

#Preview {
    MathQuizSettingsView()
}
