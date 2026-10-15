//
//  ToyFeature.swift
//  KidToys Watch App
//
//  功能注册表 —— 首页所有入口都在这里登记。
//
//  加一个新玩具只要三步：
//    1. 在下面的 enum 里加一个 case；
//    2. 填上 title / icon / tint；
//    3. 到 ToyFeatureView 的 switch 里指向新页面。
//  首页会自动多出一个大按钮，不用改 HomeView。
//

import SwiftUI

/// 首页按钮上的图标。
/// SF Symbols 里没有光秃秃的数字/字母（只有 1.circle.fill 这种带底盘的），
/// 所以数字、字母类功能直接用文字当图标，反而更直观。
enum ToyIcon {
    case symbol(String)
    case text(String)
}

enum ToyFeature: String, CaseIterable, Identifiable {
    case randomNumber
    case randomColor
    case mathQuiz
    case randomLetter

    var id: String { rawValue }

    /// 按钮下面的标签。低龄孩子靠图标认，这行字主要是给家长看的
    var title: String {
        switch self {
        case .randomNumber: return "随机数字"
        case .randomColor: return "随机颜色"
        case .mathQuiz: return "加减法"
        case .randomLetter: return "随机字母"
        }
    }

    var icon: ToyIcon {
        switch self {
        case .randomNumber: return .text("1")
        case .randomColor: return .symbol("paintpalette.fill")
        case .mathQuiz: return .symbol("plus.forwardslash.minus")
        case .randomLetter: return .text("A")
        }
    }

    /// 主题色：每个功能一个颜色，孩子靠颜色区分
    var tint: Color {
        switch self {
        case .randomNumber: return .orange
        case .randomColor: return .purple
        case .mathQuiz: return .teal
        case .randomLetter: return .green
        }
    }
}
