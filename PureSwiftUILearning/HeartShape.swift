//
//  HeartShape.swift
//  PureSwiftUILearning
//
//  Created by Matthew Young on 10/18/23.
//

//import SwiftUI      //
import PureSwiftUI    // SwiftUI簡體化 == SwiftUISimplify

// Add macro to simplify creating user Preference-like 



private let heartColor = Color(red: 225 / 255, green: 40 / 255, blue: 48 / 255)
private let heartLayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 10)

private typealias Curve = (p: CGPoint, cp1: CGPoint, cp2: CGPoint)




struct FooShape: Shape {
  var debug = false
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    path.addEllipse(in: rect)   // if I add this, I can see the below curve
    
    let g = heartLayoutConfig.layout(in: rect)
    
    // expect to see a curve from .topLeading to .bottomTrailing
    // but see nothing on screen, Xcode Version 15.1 beta (15C5028h), iOS 17
    path.curve(g.topLeading, cp1: g.bottomLeading, cp2: g.topTrailing, showControlPoints: debug)
    path.curve(g.bottomTrailing, cp1: g.bottomLeading, cp2: g.topTrailing)

    path.closeSubpath()

    return path
  }
}



struct FooView: View {
  var body: some View {
    FooShape(debug: true)
      .stroke(.mint, lineWidth: 5)
      .fill(.red)
  }
}


#Preview("FooView") {
  FooView()
}



  
private struct Heart: Shape {
  private let debug: Bool

  init(debug: Bool = true) {
    self.debug = debug
  }
  
  // but this, doesn't show a triangle
  func path(in rect: CGRect) -> Path {
    var path = Path()

    let g = heartLayoutConfig.layout(in: rect)
    
    let p1 = g[0, 3]
    let p2 = g[4, 2]
    let p3 = g[8, 3]
    let p4 = g[4, 10]
    
    var curves = [Curve]()
    
    // c1
    curves.append(Curve(p2, g[0, 0], g[4, 0]))
    
    // c2
    curves.append(Curve(p3, p2, p3))
    
    // c3
    curves.append(Curve(p4, p3, p4))
    
    // c4
    curves.append(Curve(p1, p4, p1))
    
    for curve in curves {
      path.curve(curve.p, cp1: curve.cp1, cp2: curve.cp2, showControlPoints: debug)
    }
    
    return path
  }
}

struct HeartShapeDemo_Harness: View {
  var body: some View {
    VStack(spacing: 50) {
      Heart()
        .fill(heartColor)
        .stroke(.green, lineWidth: 3)
        .frame(200)
      ZStack {
        Image(.heart)
          .resizedToFit(200)
        Heart()
          .stroke(.black, lineWidth: 2)
          .layoutGuide(heartLayoutConfig)
          .frame(200)
      }
    }
  }
}


#Preview(traits: .sizeThatFitsLayout) {
  HeartShapeDemo_Harness()
    .showLayoutGuides(true)
}
