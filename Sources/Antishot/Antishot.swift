//
//  Antishot.swift
//
//
//  Created by Sidney Liu on 7/22/24.
//

#if !os(watchOS)

import SwiftUI

public extension View {
    
    /// Prevent or control screenshot and screen recording behavior.
    /// - Parameter type: The type of screenshot and screen recording control to apply. Defaults to `.antishot`.
    /// - Returns: A view with the applied screenshot and screen recording control.
    func antishot(_ type: AntishotType = .antishot) -> some View {
        modifier(AntishotModifier(type: type))
    }
    
    /// Prevent or control screenshot and screen recording behavior with an optional hint view.
    /// - Parameters:
    ///   - type: The type of screenshot and screen recording control to apply. Defaults to `.antishot`.
    ///   - hintView: An optional view that will display hint information when the user attempts to screenshot or screen record.
    /// - Returns: A view with the applied screenshot and screen recording control and optional hint view.
    func antishot<Hint: View>(_ type: AntishotType = .antishot, hintView: (() -> Hint)? = nil) -> some View {
        modifier(AntishotModifier(type: type, hintView: hintView))
    }
}

#endif
