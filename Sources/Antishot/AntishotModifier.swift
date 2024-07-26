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

fileprivate struct AntishotAnchorView: UIViewControllerRepresentable {
    let id: UUID
    let isOverlay: Bool
    var type: AntishotType = .antishot
    func makeUIViewController(context: Context) -> AntishotAnchorUIViewController {
        return AntishotAnchorUIViewController(id: id, type: type, isOverlay: isOverlay)
    }
    func updateUIViewController(_ uiViewController: AntishotAnchorUIViewController, context: Context) {
        uiViewController.type = type
    }
}

fileprivate enum AntishotViewStore {
    static var anchorBackgroundViews: NSMapTable<NSUUID, UIView> = .strongToWeakObjects()
}

final class AntishotAnchorUIViewController: UIViewController {
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
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
        view.antishotID = id
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        makeAntishot()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        makeAntishot()
    }
    
    func makeAntishot() {
        if !isOverlay {
            AntishotViewStore.anchorBackgroundViews.setObject(view, forKey: id as NSUUID)
        } else {
            if cachedTargetViews.setRepresentation.isEmpty {
                findTargetViews().forEach { cachedTargetViews.add($0) }
            }
            cachedTargetViews.allObjects.forEach({ $0.layer.makeAntishot(type) })
        }
    }
    
    func findTargetViews() -> any Sequence<UIView> {
        guard let pairedView = AntishotViewStore.anchorBackgroundViews.object(forKey: id as NSUUID),
              let ancestor = view.nearestCommonAncestor(with: pairedView) else { return [] }
        return ancestor.allSubviewsDFS()
            .lazy
            .drop(while: { $0 != self.view })
            .prefix(while: { $0 == self.view || $0.antishotID != self.id })
            .filter({ !self.view.isDescendant(of: $0) && !pairedView.isDescendant(of: $0) })
    }
}

#endif
#endif
