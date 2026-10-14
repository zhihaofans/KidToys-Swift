//
//  ToyFeature.swift
//  KidToys Watch App
//
//  功能注册表 —— 首页所有入口都在这里登记。
//
//  加一个新玩具只要三步：
//    1. 在下面的 enum 里加一个 case；
//    2. 填上 title / symbol / tint；
//    3. 到 ToyFeatureView 的 switch 里指向新页面。
//  首页会自动多出一个大按钮，不用改 HomeView。
//

import SwiftUI

enum ToyFeature: String, CaseIterable, Identifiable {
    case randomNumber
    case randomColor

    var id: String { rawValue }

    /// 按钮下面的标签。低龄孩子靠图标认，这行字主要是给家长看的
    var title: String {
        switch self {
        case .randomNumber: return "随机数字"
        case .randomColor: return "随机颜色"
        }
    }

    /// SF Symbol 名称
    var symbol: String {
        switch self {
        case .randomNumber: return "die.face.6.fill"
        case .randomColor: return "paintpalette.fill"
        }
    }

    /// 主题色：每个功能一个颜色，孩子靠颜色区分
    var tint: Color {
        switch self {
        case .randomNumber: return .orange
        case .randomColor: return .purple
        }
    }
}
