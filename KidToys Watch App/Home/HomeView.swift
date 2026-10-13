//
//  HomeView.swift
//  KidToys Watch App
//
//  首页：把 ToyFeature 注册表里的功能铺成两列大按钮。
//  新增功能不用改这里。
//

import SwiftUI

struct HomeView: View {
    /// 只有一个玩具时铺满整行（对孩子来说更好点），两个以上排成两列
    private var columns: [GridItem] {
        let count = ToyFeature.allCases.count <= 1 ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(ToyFeature.allCases) { feature in
                        NavigationLink(value: feature) {
                            ToyButton(feature: feature)
                        }
                        // .plain 去掉系统按钮的按压变暗，颜色完全由我们自己控制
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 8)
            }
            // 功能还少的时候让按钮在垂直方向居中；加满了就自然变成正常滚动
            .defaultScrollAnchor(.center)
            .navigationDestination(for: ToyFeature.self) { feature in
                ToyFeatureView(feature: feature)
            }
        }
    }
}

#Preview {
    HomeView()
}
