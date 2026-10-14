//
//  HomeView.swift
//  KidToys Watch App
//
//  首页：把 ToyFeature 注册表里的功能铺成两列大按钮。
//  新增功能不用改这里。
//

import SwiftUI

struct HomeView: View {
    /// 标题直接读 Info.plist 的 CFBundleDisplayName，避免和构建设置里的名字写两份
    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "小小玩具箱"
    }

    /// 只有一个玩具时铺满整行（对孩子来说更好点），两个以上排成两列
    private var columns: [GridItem] {
        let count = ToyFeature.allCases.count <= 1 ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // 左上角放 app 名：右上角是系统时间，这样两边都不空
                Text(appName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 8)
                    .padding(.top, 2)

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
            }
            .navigationDestination(for: ToyFeature.self) { feature in
                ToyFeatureView(feature: feature)
            }
        }
    }
}

#Preview {
    HomeView()
}
