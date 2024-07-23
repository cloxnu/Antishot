//
//  AntishotView.swift
//
//
//  Created by Sidney Liu on 7/22/24.
//

#if canImport(UIKit) && !os(watchOS)

import SwiftUI

public struct AntishotView<Content: View>: UIViewControllerRepresentable {
    @Binding var size: CGSize
    var content: () -> Content
    
    public func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let controller = UIHostingController(rootView: content())
        controller.view.backgroundColor = .clear
        controller.view.layer.makeAntishot()
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        uiViewController.view.frame = .init(origin: .zero, size: size)
    }
}

#endif
