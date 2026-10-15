//
//  ToyFeatureView.swift
//  KidToys Watch App
//
//  功能路由：把注册表里的 case 映射到具体页面。
//  加新功能时，这里补一个分支即可。
//

import SwiftUI

struct ToyFeatureView: View {
    let feature: ToyFeature

    var body: some View {
        switch feature {
        case .randomNumber:
            RandomNumberView()
        case .randomColor:
            RandomColorView()
        case .mathQuiz:
            MathQuizView()
        case .randomLetter:
            RandomLetterView()
        }
    }
}

#Preview {
    ToyFeatureView(feature: .randomNumber)
}
