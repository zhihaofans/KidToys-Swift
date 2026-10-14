//
//  ToyColor.swift
//  KidToys Watch App
//
//  给 3 岁小孩认颜色用的色板：只挑日常最常见、说法最统一的颜色。
//  每个颜色自带 RGB，好处是能算亮度，决定文字用黑色还是白色 —— 不然黄色、白色
//  底上放白字会看不见。
//

import SwiftUI

struct ToyColor: Identifiable, Hashable {
    let id: String
    let name: String
    let red: Double
    let green: Double
    let blue: Double

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    /// 感知亮度（人眼对绿色最敏感、蓝色最不敏感），超过阈值就算浅色底
    var isLight: Bool {
        0.299 * red + 0.587 * green + 0.114 * blue > 0.68
    }

    /// 在当前底色上看得清的文字颜色
    var foreground: Color {
        isLight ? .black : .white
    }
}

enum ToyPalette {
    static let all: [ToyColor] = [
        ToyColor(id: "red", name: "红色", red: 0.90, green: 0.22, blue: 0.21),
        ToyColor(id: "orange", name: "橙色", red: 0.98, green: 0.55, blue: 0.09),
        ToyColor(id: "yellow", name: "黄色", red: 1.00, green: 0.84, blue: 0.13),
        ToyColor(id: "green", name: "绿色", red: 0.30, green: 0.72, blue: 0.30),
        ToyColor(id: "blue", name: "蓝色", red: 0.20, green: 0.47, blue: 0.90),
        ToyColor(id: "purple", name: "紫色", red: 0.58, green: 0.35, blue: 0.85),
        ToyColor(id: "pink", name: "粉色", red: 1.00, green: 0.60, blue: 0.75),
        ToyColor(id: "brown", name: "棕色", red: 0.55, green: 0.36, blue: 0.22),
        ToyColor(id: "white", name: "白色", red: 0.98, green: 0.98, blue: 0.98),
        ToyColor(id: "black", name: "黑色", red: 0.10, green: 0.10, blue: 0.12),
    ]
}
