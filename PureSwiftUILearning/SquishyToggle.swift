//
//  SquishyToggle.swift
//  PureSwiftUILearning
//
//  Created by Matthew Young on 10/19/23.
//

// Part 1: https://www.youtube.com/watch?v=WWEJVJoYk10
// Part 2: https://www.youtube.com/watch?v=scODkRbmSzE
// Part 3: https://www.youtube.com/watch?v=hEKwhUDWX9o

import PureSwiftUI


private let frameLayoutConfig = LayoutGuideConfig.grid(columns: [0.25, 0.4, 0.6, 0.75], rows: 2)

private let buttonDiameterRatio = 0.9
private let duration = 1.0

private let stateIconConfig: LayoutGuideConfig = {
  let controlPointOffsetRatio: CGFloat = 0.552
  let controlPointOffsetInUnitSquare = controlPointOffsetRatio * 0.5
  let columnsAndRows = [
    0,
    0.5 - controlPointOffsetInUnitSquare,
    0.5,
    0.5 + controlPointOffsetInUnitSquare,
    1
  ]
  return LayoutGuideConfig.grid(columns: columnsAndRows, rows: columnsAndRows)
}()


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
          .animation(.linear(duration: duration), value: isOn)
        
        Group {
          ToggleButton()
            .frame(size.heightScaled(buttonDiameterRatio))
          
          ToggleStateIcon(isOn, debug: debug)
            .styling(lineWidth: size.widthScaled(0.04))
            .frame(size.halfHeight)
            .layoutGuide(stateIconConfig, color: .red, lineWidth: 1, opacity: 1)
        }
        .xOffsetIfNot(debug, isOn ? size.halfHeight : -size.halfHeight)
        .animation(.easeInOut(duration: duration), value: isOn)
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
  
  private func calculateSize(from geo: GeometryProxy) -> CGSize {
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
      debugStyling()
    } else {
      fill(color)
    }
  }

}


private let outterGradient = LinearGradient([.white(0.45), .white(0.95)], to: .topLeading)

private struct ToggleButton: View {
  var body: some View {
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


private struct ToggleStateIcon: Shape {
  
  var animatableData: CGFloat
  private let debug: Bool
  
  init(_ isOn: Bool, debug: Bool = false) {
    animatableData = isOn ? 1 : 0
    self.debug = debug
  }
    
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    let g = stateIconConfig.layout(in: rect)
    
    path.move(g.leading.to(g.center, animatableData))
    path.curve(
      g.top,
      cp1: g[0, 1].to(g[2, 1], animatableData),
      cp2: g[1, 0].to(g.top.yOffset(1), animatableData),
      showControlPoints: debug
    )
    path.curve(
      g.trailing.to(g.center, animatableData),
      cp1: g[3, 0].to(g.top.yOffset(1), animatableData),
      cp2: g[4, 1].to(g[2, 1], animatableData),
      showControlPoints: debug
    )
    path.curve(
      g.bottom,
      cp1: g[4, 3].to(g[2, 3], animatableData),
      cp2: g[3, 4].to(g.bottom.yOffset(-1), animatableData),
      showControlPoints: debug
    )
    path.curve(
      g.leading.to(g.center, animatableData),
      cp1: g[1, 4].to(g.bottom.yOffset(-1), animatableData),
      cp2: g[0, 3].to(g[2, 3], animatableData),
      showControlPoints: debug
    )

    path.closeSubpath()
    
    return path
  }
  
  @ViewBuilder
  func styling(lineWidth: CGFloat) -> some View {
    if debug {
      debugStyling()
    } else {
      stroke(style: .init(lineWidth: lineWidth, lineJoin: .round))
    }
  }

}

private extension Shape {
  func debugStyling() -> some View {
    strokeColor(.black, lineWidth: 2)
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
