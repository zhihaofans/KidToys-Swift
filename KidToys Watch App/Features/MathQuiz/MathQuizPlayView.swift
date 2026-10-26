//
//  MathQuizPlayView.swift
//  KidToys Watch App
//
//  随机加减法（小孩玩的这一页）。显示一道 10 以内整数加减法，下面 3 个按钮选答案。
//  选对：全屏绿勾，然后自动出下一题；选错：全屏红叉，回到同一题继续选，不惩罚。
//
//  出加法还是减法由设置页的两个开关决定，读到 SettingKeys 里持久化的值。
//

import SwiftUI

struct MathQuizPlayView: View {
    // 家长在左滑那页选的题型，这里跟着变。
    // 默认值用折算结果：老数据只有两个开关时，也能选对出题类型
    @AppStorage(MathQuizSettings.modeKey)
    private var modeRaw = MathQuizSettings.currentMode().rawValue

    private var mode: MathQuizMode {
        MathQuizMode(rawValue: modeRaw) ?? MathQuizSettings.defaultMode
    }
    private var allowPlus: Bool { mode.allowPlus }
    private var allowMinus: Bool { mode.allowMinus }

    @State private var question: MathQuestion
    @State private var options: [Int]
    @State private var feedback: FeedbackKind?
    @State private var correctTick = 0
    @State private var wrongTick = 0
    /// 这道题已经点错过的答案（去重）。点满 options.count - 1 个就换题。
    @State private var eliminated: Set<Int> = []

    enum FeedbackKind {
        case correct
        case wrong
    }

    init() {
        // init 里读不到 @AppStorage，直接读 UserDefaults 取当前题型来出第一道题
        let mode = MathQuizSettings.currentMode()
        let q = MathQuestion.random(allowPlus: mode.allowPlus, allowMinus: mode.allowMinus)
        _question = State(initialValue: q)
        _options = State(initialValue: q.options())
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.teal, .indigo],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if let feedback {
                feedbackOverlay(feedback)
                    .transition(.opacity)
            } else {
                questionView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: feedback)
        .sensoryFeedback(.success, trigger: correctTick)
        .sensoryFeedback(.error, trigger: wrongTick)
        // 题型被家长改掉之后，正显示着的那道题如果不合规就换掉
        .onChange(of: modeRaw) { _, _ in dropQuestionIfDisallowed() }
    }

    // MARK: - 题目 + 选项

    private var questionView: some View {
        VStack(spacing: 16) {
            Text(question.expression)
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            HStack(spacing: 10) {
                ForEach(options, id: \.self) { value in
                    answerButton(value)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
    }

    private func answerButton(_ value: Int) -> some View {
        Button {
            choose(value)
        } label: {
            Text("\(value)")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 对错反馈

    private func feedbackOverlay(_ kind: FeedbackKind) -> some View {
        ZStack {
            (kind == .correct ? Color.green : Color.red)
                .ignoresSafeArea()

            Image(systemName: kind == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 92, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - 逻辑

    private func choose(_ value: Int) {
        guard feedback == nil else { return }

        if value == question.answer {
            feedback = .correct
            correctTick += 1
            Task {
                try? await Task.sleep(for: .seconds(1.1))
                nextQuestion()
            }
            return
        }

        feedback = .wrong
        wrongTick += 1
        eliminated.insert(value)

        // 错到只剩正确答案没试过，就直接换下一题：
        // 3 个答案最多错 2 次，答案数变了这里自然跟着变（N 个答案能错 N-1 次）。
        // 不这么做的话，孩子可以一个个点过去，最后一下必然是对的。
        let outOfTries = eliminated.count >= options.count - 1

        Task {
            try? await Task.sleep(for: .seconds(0.9))
            if outOfTries {
                nextQuestion()
            } else {
                // 只关掉红叉，回到同一题继续选
                feedback = nil
            }
        }
    }

    private func nextQuestion() {
        question = .random(allowPlus: allowPlus, allowMinus: allowMinus)
        options = question.options()
        eliminated.removeAll()
        feedback = nil
    }

    /// 当前这道题的运算符被家长关掉了，就换成允许的题型
    private func dropQuestionIfDisallowed() {
        let allowed: Bool = switch question.op {
        case .plus: allowPlus
        case .minus: allowMinus
        }

        guard !allowed else { return }
        nextQuestion()
    }
}

#Preview {
    MathQuizPlayView()
}
