//
//  MathQuizSettings.swift
//  KidToys Watch App
//
//  加减法出哪种题型。加法和减法各一个开关，至少要留一个。
//  要改持久化键、改默认值都在这里。
//

import Foundation

enum MathQuizSettings {
    /// UserDefaults 键（@AppStorage 用），家长设一次就记住
    static let plusKey = "mathQuiz.plusEnabled"
    static let minusKey = "mathQuiz.minusEnabled"

    /// 默认两种都出题
    static let plusDefault = true
    static let minusDefault = true

    /// 直接读 UserDefaults，给 init 用 —— @AppStorage 在 init 里拿不到值
    static func load() -> (plus: Bool, minus: Bool) {
        let defaults = UserDefaults.standard
        let plus = defaults.object(forKey: plusKey) as? Bool ?? plusDefault
        let minus = defaults.object(forKey: minusKey) as? Bool ?? minusDefault
        return (plus, minus)
    }
}
