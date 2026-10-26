//
//  MathQuizSettings.swift
//  KidToys Watch App
//
//  加减法出哪种题型：只加法 / 都出 / 只减法，三档。
//  要改持久化键、改默认值都在这里。
//

import Foundation

/// 出题类型。左 → 右三档，顺序和设置页上的滑块一致。
enum MathQuizMode: Int, CaseIterable, Identifiable {
    case plusOnly = 0
    case both = 1
    case minusOnly = 2

    var id: Int { rawValue }

    /// 滑块上显示的字（两个字以内，手表屏幕窄）
    var title: String {
        switch self {
        case .plusOnly: return "加法"
        case .both: return "都出"
        case .minusOnly: return "减法"
        }
    }

    /// 滑块下面那句说明
    var caption: String {
        switch self {
        case .plusOnly: return "只出加法题"
        case .both: return "加法和减法都出"
        case .minusOnly: return "只出减法题"
        }
    }

    var allowPlus: Bool { self != .minusOnly }
    var allowMinus: Bool { self != .plusOnly }

    /// 往右挪一档 / 往左挪一档，到头就不动
    func stepped(by delta: Int) -> MathQuizMode {
        MathQuizMode(rawValue: rawValue + delta) ?? self
    }
}

enum MathQuizSettings {
    /// 当前题型（存 `MathQuizMode.rawValue`）
    static let modeKey = "mathQuiz.mode"

    /// 默认两样都出
    static let defaultMode = MathQuizMode.both

    /// 老版本的两个开关，只用于迁移，别再往这里写
    static let legacyPlusKey = "mathQuiz.plusEnabled"
    static let legacyMinusKey = "mathQuiz.minusEnabled"

    /// 读当前题型：优先新键；没有新键就按老版本那两个开关折算。
    ///
    /// 故意**不写盘**：读的时候偷偷写会出现「读了但没落盘」的假象，
    /// 这里只算出一个值，两个页面都拿它当 `@AppStorage` 的默认值用。
    static func currentMode() -> MathQuizMode {
        let defaults = UserDefaults.standard

        if let raw = defaults.object(forKey: modeKey) as? Int,
           let mode = MathQuizMode(rawValue: raw) {
            return mode
        }

        // 从「两个开关」的时代升级上来的老数据
        let plus = defaults.object(forKey: legacyPlusKey) as? Bool ?? true
        let minus = defaults.object(forKey: legacyMinusKey) as? Bool ?? true
        switch (plus, minus) {
        case (true, false): return .plusOnly
        case (false, true): return .minusOnly
        default: return .both   // 都开、或都关（非法）都按默认来
        }
    }
}
