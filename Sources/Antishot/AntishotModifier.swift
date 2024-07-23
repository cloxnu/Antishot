//
//  AntishotModifier.swift
//  
//
//  Created by Sidney Liu on 7/22/24.
//

#if !os(watchOS)

import SwiftUI

struct AntishotModifier<Hint: View>: ViewModifier {
    let id = UUID()
    var type: AntishotType = .antishot
    var hintView: (() -> Hint)?
    
    func body(content: Content) -> some View {
        content
#if canImport(UIKit)
            .background(
                AntishotAnchorView(id: id, isOverlay: false, type: type)
                    .frame(width: .zero, height: .zero)
                    .accessibility(hidden: true)
                    .allowsHitTesting(false)
            )
            .overlay(
                AntishotAnchorView(id: id, isOverlay: true, type: type)
                    .frame(width: .zero, height: .zero)
                    .accessibility(hidden: true)
                    .allowsHitTesting(false)
            )
            .overlay(
                hintView?()
                    .antishot(type.hintType())
            )
#endif
    }
}

extension AntishotModifier where Hint == EmptyView {
    init(type: AntishotType = .antishot, hintView: (() -> Hint)? = nil) {
        self.type = type
        self.hintView = hintView
    }
}

#if canImport(UIKit)

fileprivate struct AntishotAnchorView: UIViewRepresentable {
    let id: UUID
    let isOverlay: Bool
    var type: AntishotType = .antishot
    func makeUIView(context: Context) -> AntishotAnchorUIView {
        let view = AntishotAnchorUIView(id: id, type: type, isOverlay: isOverlay)
        return view
    }
    func updateUIView(_ uiView: AntishotAnchorUIView, context: Context) {
        uiView.type = type
    }
}

fileprivate enum AntishotViewStore {
    static var anchorBackgroundViews: NSMapTable<NSUUID, AntishotAnchorUIView> = .strongToWeakObjects()
}

final class AntishotAnchorUIView: UIView {
    let id: UUID
    let isOverlay: Bool
    var type: AntishotType = .antishot {
        didSet {
            makeAntishot()
        }
    }
    private var cachedTargetViews: NSHashTable<UIView> = .weakObjects()
    
    init(id: UUID, type: AntishotType, isOverlay: Bool) {
        self.id = id
        self.type = type
        self.isOverlay = isOverlay
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !isOverlay {
            AntishotViewStore.anchorBackgroundViews.setObject(self, forKey: id as NSUUID)
        }
        self.isAntishotAnchorOverlayView = isOverlay
        self.antishotID = id
        self.makeAntishot()
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.makeAntishot()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeAntishot()
    }
    
    func makeAntishot() {
        guard isOverlay else {
            return
        }
        if cachedTargetViews.count == 0 {
            findTargetViews().forEach { cachedTargetViews.add($0) }
        }
        makeAntishot(views: cachedTargetViews.allObjects)
    }
    
    func findTargetViews() -> any Sequence<UIView> {
        guard let pairedView = AntishotViewStore.anchorBackgroundViews.object(forKey: id as NSUUID),
              let ancestor = nearestCommonAncestor(with: pairedView) else { return [] }
        return ancestor.allSubviewsDFS()
            .lazy
            .drop(while: { !(($0.isAntishotAnchorOverlayView ?? false) && $0.antishotID == self.id) })
            .prefix(while: { ($0.isAntishotAnchorOverlayView ?? true) || $0.antishotID != self.id })
            .dropFirst()
    }
    
    func makeAntishot(views: [UIView]) {
        views.forEach { view in
            view.layer.makeAntishot(type)
        }
    }
}

#endif
#endif
