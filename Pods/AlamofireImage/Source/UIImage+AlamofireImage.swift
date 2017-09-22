// UIImage+AlamofireImage.swift
//
// Copyright (c) 2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import CoreGraphics
import Foundation
import UIKit

#if os(iOS)
import CoreImage
#endif

// MARK: Initialization

private let lock = NSLock()

extension UIImage {
    /**
        Initializes and returns the image object with the specified data in a thread-safe manner.

        It has been reported that there are thread-safety issues when initializing large amounts of images 
        simultaneously. In the event of these issues occurring, this method can be used in place of 
        the `init?(data:)` method.

        - parameter data: The data object containing the image data.

        - returns: An initialized `UIImage` object, or `nil` if the method failed.
    */
    public static func af_threadSafeImageWithData(_ data: Data) -> UIImage? {
        lock.lock()
        let image = UIImage(data: data)
        lock.unlock()

        return image
    }

    /**
        Initializes and returns the image object with the specified data and scale in a thread-safe manner.

        It has been reported that there are thread-safety issues when initializing large amounts of images
        simultaneously. In the event of these issues occurring, this method can be used in place of
        the `init?(data:scale:)` method.

        - parameter data:  The data object containing the image data.
        - parameter scale: The scale factor to assume when interpreting the image data. Applying a scale factor of 1.0 
                           results in an image whose size matches the pixel-based dimensions of the image. Applying a 
                           different scale factor changes the size of the image as reported by the size property.

        - returns: An initialized `UIImage` object, or `nil` if the method failed.
    */
    public static func af_threadSafeImageWithData(_ data: Data, scale: CGFloat) -> UIImage? {
        lock.lock()
        let image = UIImage(data: data, scale: scale)
        lock.unlock()

        return image
    }
}

// MARK: - Inflation

extension UIImage {
    fileprivate struct AssociatedKeys {
        static var InflatedKey = "af_UIImage.Inflated"
    }

    /// Returns whether the image is inflated.
    public var af_inflated: Bool {
        get {
            if let inflated = objc_getAssociatedObject(self, &AssociatedKeys.InflatedKey) as? Bool {
                return inflated
            } else {
                return false
            }
        }
        set(inflated) {
            objc_setAssociatedObject(self, &AssociatedKeys.InflatedKey, inflated, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
        Inflates the underlying compressed image data to be backed by an uncompressed bitmap representation.

        Inflating compressed image formats (such as PNG or JPEG) can significantly improve drawing performance as it
        allows a bitmap representation to be constructed in the background rather than on the main thread.
    */
    public func af_inflate() {
        guard !af_inflated else { return }

        af_inflated = true
        cgImage?.dataProvider?.data
    }
}

// MARK: - Scaling

extension UIImage {
    /**
        Returns a new version of the image scaled to the specified size.

        - parameter size: The size to use when scaling the new image.

        - returns: A new image object.
    */
    public func af_imageScaledToSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage!
    }

    /**
        Returns a new version of the image scaled from the center while maintaining the aspect ratio to fit within 
        a specified size.

        - parameter size: The size to use when scaling the new image.

        - returns: A new image object.
    */
    public func af_imageAspectScaledToFitSize(_ size: CGSize) -> UIImage {
        let imageAspectRatio = self.size.width / self.size.height
        let canvasAspectRatio = size.width / size.height

        var resizeFactor: CGFloat

        if imageAspectRatio > canvasAspectRatio {
            resizeFactor = size.width / self.size.width
        } else {
            resizeFactor = size.height / self.size.height
        }

        let scaledSize = CGSize(width: self.size.width * resizeFactor, height: self.size.height * resizeFactor)
        let origin = CGPoint(x: (size.width - scaledSize.width) / 2.0, y: (size.height - scaledSize.height) / 2.0)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: origin, size: scaledSize))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage!
    }

    /**
        Returns a new version of the image scaled from the center while maintaining the aspect ratio to fill a
        specified size. Any pixels that fall outside the specified size are clipped.

        - parameter size: The size to use when scaling the new image.

        - returns: A new image object.
    */
    public func af_imageAspectScaledToFillSize(_ size: CGSize) -> UIImage {
        let imageAspectRatio = self.size.width / self.size.height
        let canvasAspectRatio = size.width / size.height

        var resizeFactor: CGFloat

        if imageAspectRatio > canvasAspectRatio {
            resizeFactor = size.height / self.size.height
        } else {
            resizeFactor = size.width / self.size.width
        }

        let scaledSize = CGSize(width: self.size.width * resizeFactor, height: self.size.height * resizeFactor)
        let origin = CGPoint(x: (size.width - scaledSize.width) / 2.0, y: (size.height - scaledSize.height) / 2.0)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: origin, size: scaledSize))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage!
    }
}

// MARK: - Rounded Corners

extension UIImage {
    /**
        Returns a new version of the image with the corners rounded to the specified radius.

        - parameter radius:                   The radius to use when rounding the new image.
        - parameter divideRadiusByImageScale: Whether to divide the radius by the image scale. Set to `true` when the 
                                              image has the same resolution for all screen scales such as @1x, @2x and 
                                              @3x (i.e. single image from web server). Set to `false` for images loaded 
                                              from an asset catalog with varying resolutions for each screen scale. 
                                              `false` by default.

        - returns: A new image object.
    */
    public func af_imageWithRoundedCornerRadius(_ radius: CGFloat, divideRadiusByImageScale: Bool = false) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        let scaledRadius = divideRadiusByImageScale ? radius / scale : radius

        let clippingPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), cornerRadius: scaledRadius)
        clippingPath.addClip()

        draw(in: CGRect(origin: CGPoint.zero, size: size))

        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return roundedImage!
    }

    /**
        Returns a new version of the image rounded into a circle.

        - returns: A new image object.
    */
    public func af_imageRoundedIntoCircle() -> UIImage {
        let radius = min(size.width, size.height) / 2.0
        var squareImage = self

        if size.width != size.height {
            let squareDimension = min(size.width, size.height)
            let squareSize = CGSize(width: squareDimension, height: squareDimension)
            squareImage = af_imageAspectScaledToFillSize(squareSize)
        }

        UIGraphicsBeginImageContextWithOptions(squareImage.size, false, 0.0)

        let clippingPath = UIBezierPath(
            roundedRect: CGRect(origin: CGPoint.zero, size: squareImage.size),
            cornerRadius: radius
        )

        clippingPath.addClip()

        squareImage.draw(in: CGRect(origin: CGPoint.zero, size: squareImage.size))

        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return roundedImage!
    }
}

#if os(iOS)

// MARK: - Core Image Filters

extension UIImage {
    /**
        Returns a new version of the image using a CoreImage filter with the specified name and parameters.

        - parameter filterName:       The name of the CoreImage filter to use on the new image.
        - parameter filterParameters: The parameters to apply to the CoreImage filter.

        - returns: A new image object, or `nil` if the filter failed for any reason.
    */
    public func af_imageWithAppliedCoreImageFilter(
        _ filterName: String,
        filterParameters: [String: AnyObject]? = nil) -> UIImage?
    {
        var image: CoreImage.CIImage? = ciImage

        if image == nil, let CGImage = self.cgImage {
            image = CoreImage.CIImage(cgImage: CGImage)
        }

        guard let coreImage = image else { return nil }

        let context = CIContext(options: [kCIContextPriorityRequestLow: true])

        var parameters: [String: AnyObject] = filterParameters ?? [:]
        parameters[kCIInputImageKey] = coreImage

        guard let filter = CIFilter(name: filterName, withInputParameters: parameters) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        let cgImageRef = context.createCGImage(outputImage, from: coreImage.extent)

        return UIImage(cgImage: cgImageRef!, scale: scale, orientation: imageOrientation)
    }
}

#endif
