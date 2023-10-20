//
//  InnerShadowsReduxDemo.swift
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
//  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//  Copyright © 2022 Adam Fordyce. All rights reserved.
//

// https://www.youtube.com/watch?v=jHUlEs9MNNM&t=45s

import PureSwiftUI

private let gradient = LinearGradient([.red, .yellow], to: .bottomTrailing)
private let roundedRectangleCornerRadius = 40.0

struct InnerShadowsReduxDemo: View {

    @State private var text = ""
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        
        let itemSize: Double = 200
        
        let textFieldExample = TextField("Here is a TextField", text: $text)
            .textFieldStyle()

        let textEditorExample = TextEditor(text: $text)
            .textEditorStyle()

        let textExample = Text("INNER\nSHADOWS")
            .multilineTextAlignment(.center)
            .fixedSize()
            .customFont(90, .bold)
            .withGradientOverlay()
        
        let shapeExample = RoundedRectangle(roundedRectangleCornerRadius)
            .fill(gradient)
            .frame(itemSize)
        
        let complexViewExample = LayeredView()
            .frame(itemSize)
        
        let sfSymbolExample = SFSymbol(.music_note_house_fill)
            .resizedToFit(itemSize)
            .withGradientOverlay()
        
        let imageExample = Image("dots")
            .renderingMode(.template)
            .resizedToFit(itemSize)
            .foregroundStyle(gradient)

        VStack(spacing: 30) {
            textFieldExample
                .innerShadow(5, opacity: 0.8, x: 2, y: 2)
            textEditorExample
                .innerShadow(5, opacity: 0.8, x: 2, y: 2)
            textExample
                .innerShadow(3, x: 5, y: 5)
            HStack(spacing: 50) {
                shapeExample
                    .innerShadow(5, opacity: 0.8, x: 2, y: 2)
                complexViewExample
                    .innerShadow(5, opacity: 0.8, x: 2, y: 2)
            }
            HStack(spacing: 50) {
                sfSymbolExample
                    .innerShadow(5, opacity: 0.8, x: 2, y: 2)
                imageExample
                    .innerShadow(5, opacity: 0.8, x: 2, y: 2)
            }
        }
        .width(500)
    }
}

private extension View {
    
    func innerShadow(_ shadowRadius: Double, opacity: Double = 0.5, x: Double = 0, y: Double = 0) -> some View {
        let opacity = opacity.clamped(min: 0, max: 1)
        return self
            .compositingGroup()
            .background(
                Color.white(1 - opacity)
                    .overlay(
                        Color.white
                            .mask(self)
                            .blur(shadowRadius)
                            .offset(x, y)
                    )
                    .mask(self)
                    .compositingGroup()
            )
            .blendMode(.multiply)
            .compositingGroup()
    }
}

private struct LayeredView: View {
    
    var body: some View {
        ZStack {
            gradient
            GeometryReader { (geo: GeometryProxy) in
                ForEach(0..<4) { index in
                    Path { path in
                        let scale = 0.8 - 0.2 * index.asDouble
                        let cornerRadius = roundedRectangleCornerRadius * scale
                        let rect = geo.localFrame.scaled(scale, at: geo.localCenter, anchor: .center)
                        path.roundedRect(rect, cornerRadius: cornerRadius)
                    }
                    .fill(gradient)
                    .shadowColor(.black.opacity(0.4), 5)
                }
            }
        }
        .cornerRadius(roundedRectangleCornerRadius)
    }
}

private extension View {

    func withGradientOverlay() -> some View {
        self.overlay(gradient.mask(self))
    }

    func textEditorStyle() -> some View {
        height(100)
            .textBoxBorder()
    }

    func textFieldStyle() -> some View {
        padding(5)
            .greedyWidth(.leading)
            .textBoxBorder()
    }

    func textBoxBorder() -> some View {
        clipRoundedRectangle(5, fill: gradient)
    }
}

struct InnerShadowsReduxDemo_Harness: View {
  
  var body: some View {
    InnerShadowsReduxDemo()
      .padding(30)
      .backgroundColor(.white(0.1))
  }
}

#Preview(traits: .sizeThatFitsLayout) {
    InnerShadowsReduxDemo_Harness()
}
