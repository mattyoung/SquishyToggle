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
  var body: some View {
    let debug = false
    
    GeometryReader { geo in
      let size = calculateSize(from: geo)
      ZStack {
        ToggleFrame(debug: debug)
          .styling(color: .green)
          .layoutGuide(frameLayoutConfig, color: .green, lineWidth: 2)
      }
      .frame(size)
      .borderIf(debug, .gray.opacity(0.2))
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
  
  private let debug: Bool
  
  init(debug: Bool = false) {
    self.debug = debug
  }
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    let g = frameLayoutConfig.layout(in: rect)
    let curveYOffset = rect.heightScaled(0.18)
    
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




struct SquishyToggle_Harness: View {
  var body: some View {
    SquishyToggle()
      .frame(400)
  }
}

#Preview {
    SquishyToggle()
}
