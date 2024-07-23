//
//  CALayer+Antishot.swift
//
//
//  Created by Sidney Liu on 7/22/24.
//

#if !os(watchOS)

import QuartzCore

public enum AntishotType {
    case disable
    case antishot
    case onlyshot
    case hidden
    
    func hintType() -> Self {
        switch self {
        case .disable: return .hidden
        case .antishot: return .onlyshot
        case .onlyshot: return .antishot
        case .hidden: return .disable
        }
    }
}

extension CALayer {
    
    /// Prevent or control screenshot and screen recording behavior.
    /// - Parameter type: The type of screenshot and screen recording control to apply. Defaults to `.antishot`.
    public func makeAntishot(_ type: AntishotType = .antishot) {
        let selector = Selector("setDisableUpdateMask:")
        guard self.responds(to: selector) else {
            return
        }
        let value: UInt32 = {
            switch type {
            case .disable: 0x0
            case .antishot: 0x12
            case .onlyshot: 0x11
            case .hidden: 0x13
            }
        }()
        let imp = self.method(for: selector)
        typealias Function = @convention(c) (AnyObject, Selector, UInt32) -> Void
        let function = unsafeBitCast(imp, to: Function.self)
        function(self, selector, value)
    }
}

#endif
