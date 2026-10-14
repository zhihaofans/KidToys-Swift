//
//  RandomNumberView.swift
//  KidToys Watch App
//
//  随机数字功能的外壳：分成两页，左滑到家长设置页，右滑回摇数字页。
//

import SwiftUI

struct RandomNumberView: View {
    var body: some View {
        TabView {
            RandomNumberRollView()
            RandomNumberRangeSettingsView()
        }
        // .page 在 watchOS 上是横向分页，可以左右滑动切换
        .tabViewStyle(.page)
    }
}

#Preview {
    RandomNumberView()
}
