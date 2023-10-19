//
//  SquishyToggle.swift
//  PureSwiftUILearning
//
//  Created by Matthew Young on 10/19/23.
//

// Part 1: https://www.youtube.com/watch?v=WWEJVJoYk10
// Part 2: https://www.youtube.com/watch?v=scODkRbmSzE


import PureSwiftUI


private let frameLayoutConfig = LayoutGuideConfig.grid(columns: [0.25, 0.4, 0.6, 0.75], rows: 2)

struct SquishyToggle: View {
  @State private var isOn = true
  
  var body: some View {
    let debug = false
    
    GeometryReader { geo in
      let size = calculateSize(from: geo)
      
      ZStack {
        ToggleFrame(isOn, debug: debug)
          .styling(color: .green)
          .layoutGuide(frameLayoutConfig, color: .green, lineWidth: 2)
          .animation(.linear(duration: 1), value: isOn)
        
        ToggleButton()
          .frame(size.heightScaled(0.9))
          .xOffset(isOn ? size.halfHeight : -size.halfHeight)
          .animation(.easeInOut(duration: 1), value: isOn)
      }
      
      .frame(size)
      .borderIf(debug, .gray.opacity(0.2))
      .contentShape(.capsule)
      .onTapGesture {
        isOn.toggle()
      }
      .greedyFrame()
    }
    .showLayoutGuides(debug)
  }
  
  func calculateSize(from geo: GeometryProxy) -> CGSize {
    let doubleHeight = geo.heightScaled(2)
    return if geo.width < doubleHeight {
      .init(geo.width, geo.halfHeight)
    } else {
      .init(doubleHeight, geo.height)
    }
  }
}



private struct ToggleFrame: Shape {
  
  var animatableData: CGFloat
  private let debug: Bool
  
  init(_ isOn: Bool, debug: Bool = false) {
    animatableData = isOn ? 1 : 0
    self.debug = debug
  }
    
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let maxCurveYOffset = rect.heightScaled(0.18)
    
    let offsetLayoutGuide = LayoutGuide.polar(.rect(.square(maxCurveYOffset)), rings: 1, segments: 1)
      .rotated(360.degrees, factor: animatableData)
    
//    path.circle(offsetLayoutGuide.center, diameter: maxCurveYOffset)
//    path.circle(offsetLayoutGuide.bottom, radius: 4)
    
    let curveYOffset = offsetLayoutGuide.bottom.y
    
    let g = frameLayoutConfig.layout(in: rect)
    
    let arcRadius = rect.halfHeight
    
    path.move(g[0, 0])
    path.curve(
      rect.top.yOffset(curveYOffset),
      cp1: g[1, 0],
      cp2: g[1, 0].yOffset(curveYOffset),
      showControlPoints: debug
    )
    path.curve(
      g[3, 0],
      cp1: g[2, 0].yOffset(curveYOffset),
      cp2: g[2, 0],
      showControlPoints: debug
    )
    path.arc(
      g[3, 1],
      radius: arcRadius,
      startAngle: .top,
      endAngle: .bottom
    )
    path.curve(
      rect.bottom.yOffset(-curveYOffset),
      cp1: g[2, 2],
      cp2: g[2, 2].yOffset(-curveYOffset),
      showControlPoints: debug
    )
    path.curve(g[0, 2], cp1: g[1, 2].yOffset(-curveYOffset), cp2: g[1, 2], showControlPoints: debug)
    path.arc(g[0, 1], radius: arcRadius, startAngle: .bottom, endAngle: .top)
    path.closeSubpath()
    
    return path
  }
  
  @ViewBuilder
  func styling(color: Color) -> some View {
    if debug {
      strokeColor(.black, lineWidth: 2)
    } else {
      fill(color)
    }
  }

}


private struct ToggleButton: View {
  var body: some View {
    let outterGradient = LinearGradient([.white(0.45), .white(0.95)], to: .topLeading)
    GeometryReader { geo in
      let innerGradient = RadialGradient(
        [.white(0.9), .white(0.3)],
        center: .bottomTrailing,
        from: geo.widthScaled(0.2),
        to: geo.widthScaled(1.5)
      )
      ZStack {
        Circle()
          .fill(outterGradient)
        Circle()
          .inset(geo.widthScaled(0.1))
          .fill(innerGradient)
      }
      .drawingGroup()
//      .shadow(5)
    }
  }
}

// MARK: - Preview stuffs
struct SquishyToggle_Harness: View {
  var body: some View {
    SquishyToggle()
      .frame(400)
  }
}

#Preview {
    SquishyToggle_Harness()
}
