//
//  MathQuizView.swift
//  KidToys Watch App
//
//  随机加减法的外壳：分成两页，左滑到家长设置页，右滑回做题页。
//  和随机数字页的操作方式保持一致。
//

import SwiftUI

struct MathQuizView: View {
    var body: some View {
        TabView {
            MathQuizPlayView()
            MathQuizSettingsView()
        }
        // .page 在 watchOS 上是横向分页，可以左右滑动切换
        .tabViewStyle(.page)
    }
}

#Preview {
    MathQuizView()
}
