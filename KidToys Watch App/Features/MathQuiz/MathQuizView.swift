//
//  MathQuizView.swift
//  KidToys Watch App
//
//  随机加减法。显示一道 10 以内整数加减法，下面 3 个按钮选答案。
//  选对：全屏绿勾，然后自动出下一题；选错：全屏红叉，回到同一题继续选，不惩罚。
//

import SwiftUI

struct MathQuizView: View {
    @State private var question: MathQuestion
    @State private var options: [Int]
    @State private var feedback: FeedbackKind?
    @State private var correctTick = 0
    @State private var wrongTick = 0

    enum FeedbackKind {
        case correct
        case wrong
    }

    init() {
        let q = MathQuestion.random()
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
        } else {
            feedback = .wrong
            wrongTick += 1
            Task {
                try? await Task.sleep(for: .seconds(0.9))
                // 只关掉红叉，回到同一题继续选
                feedback = nil
            }
        }
    }

    private func nextQuestion() {
        question = MathQuestion.random()
        options = question.options()
        feedback = nil
    }
}

#Preview {
    MathQuizView()
}
