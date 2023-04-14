//
//  File.swift
//
//
//  Created by Óscar Morales Vivó on 4/12/23.
//

#if canImport(UIKit)
import UIKit

public typealias RemoteImageCache<Identifier: ResourceIdentifier> = RemoteResourceCache<UIImage, Identifier>

public extension RemoteResourceCache where Resource == UIImage {
    struct UnableToDecodeImageFromData: Error {
        var data: Data

        var localizedDescription: String {
            "Unable to decode data into UIImage \(data)"
        }
    }

    /**
     Returns a remote image cache configured with the given data provider.

     Use this factory method to get a cache that manages UIImages and their data.
     - Parameter imageDataProvider: The data provider that retrieves the remote or locally stored image data. Defaults
     to an instance of `DefaultResourceDataProvider`
     - Returns: A newly created remote image cache.
     */
    init(imageDataProvider: ResourceDataProvider = DefaultResourceDataProvider()) {
        self.init(resourceDataProvider: imageDataProvider) { imageData in
            guard let image = UIImage(data: imageData) else {
                throw UnableToDecodeImageFromData(data: imageData)
            }

            return image
        }
    }
}
#endif
