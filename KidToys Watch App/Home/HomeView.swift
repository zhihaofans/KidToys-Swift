//
//  HomeView.swift
//  KidToys Watch App
//
//  首页：把 ToyFeature 注册表里的功能铺成两列大按钮。
//  新增功能不用改这里。
//

import SwiftUI
import CrashKit

struct HomeView: View {
    @State private var crashReport: CrashReport?
    @State private var showCrashAlert = false

    /// 只有一个玩具时铺满整行（对孩子来说更好点），两个以上排成两列
    private var columns: [GridItem] {
        let count = ToyFeature.allCases.count <= 1 ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }

    var body: some View {
        NavigationStack {
            // 不放 app 名标题：按钮多起来之后标题会和按钮挤在一起互相遮挡。
            // app 名在手表桌面和 App 列表里本来就看得到，这里不用重复。
            GeometryReader { proxy in
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
                    // 装得下就垂直居中；装不下时 frame 被撑高，滚动自然从顶部开始。
                    // 比 defaultScrollAnchor(.center) 稳：后者在内容超高时会把第一行顶到屏幕外。
                    .frame(minHeight: proxy.size.height, alignment: .center)
                }
            }
            .navigationDestination(for: ToyFeature.self) { feature in
                ToyFeatureView(feature: feature)
            }
        }
        .task {
            guard crashReport == nil else { return }
            if let report = CrashRecorder.shared.takePendingReport() {
                crashReport = report
                showCrashAlert = true
            }
        }
        .alert(crashReport?.title ?? "上次闪退了", isPresented: $showCrashAlert) {
            Button("知道了", role: .cancel) {
                crashReport = nil
            }
        } message: {
            Text(crashReport?.details ?? "")
        }
    }
}

#Preview {
    HomeView()
}
