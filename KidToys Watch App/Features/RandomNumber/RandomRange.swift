//
//  RandomRange.swift
//  KidToys Watch App
//
//  随机数字的取值范围配置。要改上下限、改持久化键都在这里。
//

import Foundation

enum RandomRange {
    /// 允许的边界，设置页的数字轮不会越过它（允许负数）
    static let lowerBound = -500
    static let upperBound = 500

    /// 默认范围
    static let defaultMin = -50
    static let defaultMax = 50

    /// UserDefaults 键（@AppStorage 用），家长设一次就记住
    static let minKey = "randomNumber.min"
    static let maxKey = "randomNumber.max"
}
