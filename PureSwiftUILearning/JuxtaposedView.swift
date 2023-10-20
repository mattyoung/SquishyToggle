//
//  JuxtaposedView.swift
//  PureSwiftUILearning
//
//  Created by Matthew Young on 10/20/23.
//


import SwiftUI

public extension View {
  func juxtapose<Content>(
    edge: Edge = .top,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View where Content: View {
    modifier(
      JuxtaposedViewModifier(
        edge: edge,
        spacing: spacing,
        juxtaposedView: content
      )
    )
  }

  func juxtapose<Content>(
    alignment: Alignment = .top,
    spacing: CGSize = .init(width: 8, height: 8),
    @ViewBuilder content: @escaping () -> Content
  ) -> some View where Content: View {
    modifier(
      JuxtaposedViewModifier(
        alignment: alignment,
        spacing: spacing,
        juxtaposedView: content
      )
    )
  }
}

public struct JuxtaposedViewModifier<JuxtaposedView: View>: ViewModifier {
  public init(
    edge: Edge = .top,
    spacing: CGFloat = 8,
    @ViewBuilder juxtaposedView: @escaping () -> JuxtaposedView
  ) {
    switch edge {
    case .top: alignment = .top
    case .leading: alignment = .leading
    case .bottom: alignment = .bottom
    case .trailing: alignment = .trailing
    }
    self.spacing = .init(width: spacing, height: spacing)
    self.juxtaposedView = juxtaposedView
  }

  public init(
    alignment: Alignment = .top,
    spacing: CGSize = .init(width: 8, height: 8),
    @ViewBuilder juxtaposedView: @escaping () -> JuxtaposedView
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.juxtaposedView = juxtaposedView
  }

  private let alignment: Alignment
  private let spacing: CGSize
  private let juxtaposedView: () -> JuxtaposedView
  public func body(content: Content) -> some View {
    content
      .overlay(
        juxtaposedView()
          .alignmentGuide(alignment.vertical) {
            $0[juxtaposedViewAlignment.vertical] + verticalSpacing
          }
          .alignmentGuide(alignment.horizontal) {
            $0[juxtaposedViewAlignment.horizontal] + horizontalSpacing
          }
          .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: alignment
          )
      )
  }

  private var horizontalSpacing: CGFloat {
    switch alignment {
    case .topLeading: fallthrough
    case .bottomLeading: fallthrough
    case .leading: return spacing.width
    case .topTrailing: fallthrough
    case .bottomTrailing: fallthrough
    case .trailing: return -spacing.width
    default: return 0
    }
  }

  private var verticalSpacing: CGFloat {
    switch alignment {
    case .topLeading: fallthrough
    case .topTrailing: fallthrough
    case .top: return spacing.height
    case .bottomLeading: fallthrough
    case .bottomTrailing: fallthrough
    case .bottom: return -spacing.height
    default: return 0
    }
  }

  private var juxtaposedViewAlignment: Alignment {
    switch alignment {
    case .leading: return .trailing
    case .trailing: return .leading
    case .top: return .bottom
    case .bottom: return .top
    case .topLeading: return .bottomTrailing
    case .topTrailing: return .bottomLeading
    case .bottomLeading: return .topTrailing
    case .bottomTrailing: return .topLeading
    default: return alignment
    }
  }
}

// MARK: Demo
struct JuxtaposedDemo: View {
  var size: CGSize
  var body: some View {
    RoundedRectangle(cornerRadius: 8)
      .strokeBorder()
      .frame(width: size.width, height: size.height)
      .juxtapose(edge: .top) {
        suit("club")
      }
      .juxtapose(edge: .bottom) {
        suit("spade")
          .juxtapose(alignment: .topTrailing, spacing: .zero) {
            Text("Player 1").font(.caption).bold().fixedSize()
          }
          .juxtapose(alignment: .bottomLeading) {
            Text("Dealer").font(.caption).bold().fixedSize()
              .juxtapose(edge: .bottom, spacing: 0) {
                Image(systemName: "star.circle.fill")
              }
          }
      }
      .juxtapose(edge: .leading, spacing: 33) {
        suit("heart")
          .foregroundColor(.red)
      }
      .juxtapose(edge: .trailing, spacing: -10) {
        suit("diamond")
          .foregroundColor(.red)
      }
  }

  func suit(_ name: String) -> some View {
    Image(systemName: "suit.\(name).fill")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(height: 33)
  }
}

struct JustaposedPreview_Harness: View {
  var body: some View {
    VStack {
      Spacer()
      JuxtaposedDemo(size: .init(width: 66, height: 66))
      Spacer()
      JuxtaposedDemo(size: .init(width: 200, height: 33))
      Spacer()
      JuxtaposedDemo(size: .init(width: 33, height: 66))
      Spacer()
    }
  }
}

#Preview {
  JustaposedPreview_Harness()
}
