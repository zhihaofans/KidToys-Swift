//
//  MathQuestion.swift
//  KidToys Watch App
//
//  加减法题目模型。10 以内的整数相加或相减。
//

import Foundation

enum MathOperator {
    case plus
    case minus

    var symbol: String {
        switch self {
        case .plus: return "+"
        case .minus: return "−"
        }
    }
}

struct MathQuestion {
    /// 操作数范围：10 以内 = 1...10
    static let operandRange = 1...10
    /// 干扰项在正确答案附近 ±3 里挑
    static let distractorSpan = 3

    let a: Int
    let b: Int
    let op: MathOperator
    let answer: Int

    var expression: String {
        "\(a) \(op.symbol) \(b) = "
    }

    /// 随机生成。减法保证 a ≥ b，结果不为负 —— 3 岁小孩不该遇到负数
    ///
    /// - Parameters:
    ///   - allowPlus: 允许出加法，来自设置页的开关
    ///   - allowMinus: 允许出减法，来自设置页的开关
    static func random(allowPlus: Bool = true, allowMinus: Bool = true) -> MathQuestion {
        let x = Int.random(in: operandRange)
        let y = Int.random(in: operandRange)

        // 两个都关掉是非法状态（设置页会拦），真出现了也只出加法，保证一定有题
        let op: MathOperator
        if allowPlus && allowMinus {
            op = Bool.random() ? .plus : .minus
        } else if allowMinus {
            op = .minus
        } else {
            op = .plus
        }

        switch op {
        case .plus:
            return MathQuestion(a: x, b: y, op: .plus, answer: x + y)
        case .minus:
            let high = max(x, y)
            let low = min(x, y)
            return MathQuestion(a: high, b: low, op: .minus, answer: high - low)
        }
    }

    /// 正确答案 + 若干不重复、非负的干扰项，顺序打乱
    func options(count: Int = 3) -> [Int] {
        var set = Set<Int>([answer])
        let candidates = (max(0, answer - Self.distractorSpan)...(answer + Self.distractorSpan))
            .filter { $0 != answer }
            .shuffled()

        for value in candidates {
            guard set.count < count else { break }
            set.insert(value)
        }
        return set.shuffled()
    }
}
