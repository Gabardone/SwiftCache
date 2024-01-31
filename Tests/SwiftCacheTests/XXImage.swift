//
//  XXImage.swift
//
//
//  Created by Óscar Morales Vivó on 1/28/24.
//

import Foundation

#if os(macOS)
import Cocoa

// Shuts up the `Sendable` warnings in the tests.
extension NSImage: @unchecked Sendable {}

typealias XXImage = NSImage

extension XXImage {
    static let sampleImage: NSImage = {
        let imageSize = CGSize(width: 256.0, height: 256.0)
        return NSImage(size: imageSize, flipped: false) { rect in
            NSColor.yellow.setFill()
            NSBezierPath.fill(rect)
            NSColor.blue.setFill()
            NSBezierPath(ovalIn: .init(
                x: imageSize.width / 8.0,
                y: imageSize.height / 8.0,
                width: imageSize.width / 4.0,
                height: imageSize.height / 4.0
            )
            ).fill()
            NSBezierPath(ovalIn: .init(
                x: (imageSize.width * 5.0) / 8.0,
                y: (imageSize.height * 5.0) / 8.0,
                width: imageSize.width / 4.0,
                height: imageSize.height / 4.0
            )
            ).fill()

            return true
        }
    }()

    static let sampleImageData: Data = sampleImage.tiffRepresentation!
}
#else
import UIKit

typealias XXImage = UIImage

extension XXImage {
    static let sampleImage: UIImage = {
        let imageSize = CGSize(width: 256.0, height: 256.0)
        UIGraphicsBeginImageContext(imageSize)
        defer {
            UIGraphicsEndImageContext()
        }

        let context = UIGraphicsGetCurrentContext()!
        UIColor.yellow.setFill()
        context.fill(.init(origin: .zero, size: imageSize))
        UIColor.blue.setFill()
        UIBezierPath(ovalIn: .init(
            x: imageSize.width / 8.0,
            y: imageSize.height / 8.0,
            width: imageSize.width / 4.0,
            height: imageSize.height / 4.0
        )
        ).fill()
        UIBezierPath(ovalIn: .init(
            x: (imageSize.width * 5.0) / 8.0,
            y: (imageSize.height * 5.0) / 8.0,
            width: imageSize.width / 4.0,
            height: imageSize.height / 4.0
        )
        ).fill()

        return UIGraphicsGetImageFromCurrentImageContext()!
    }()

    static let sampleImageData: Data = sampleImage.pngData()!
}
#endif
