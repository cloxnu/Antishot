//
//  UIView+.swift
//
//
//  Created by Sidney Liu on 7/23/24.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UIView {
    func allSubviewsDFS() -> AnySequence<UIView> {
        return AnySequence { () -> AnyIterator<UIView> in
            var stack: [UIView] = [self]
            
            return AnyIterator {
                while !stack.isEmpty {
                    let view = stack.removeLast()
                    stack.append(contentsOf: view.subviews)
                    return view
                }
                return nil
            }
        }
    }

    func nearestCommonAncestor(with other: UIView) -> UIView? {
        var nearestAncestor: UIView? = self

        while let currentEntity = nearestAncestor, !other.isDescendant(of: currentEntity) {
            nearestAncestor = currentEntity.superview
        }

        return nearestAncestor
    }
    
    var isAntishotAnchorOverlayView: Bool? {
        get {
            let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
            return objc_getAssociatedObject(self, key) as? Bool
        }
        set {
            let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var antishotID: UUID? {
        get {
            let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
            return objc_getAssociatedObject(self, key) as? UUID
        }
        set {
            let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

#endif
