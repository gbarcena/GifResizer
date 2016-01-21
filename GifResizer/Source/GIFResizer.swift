//
//  GIFResizer.swift
//
//  Created by Gustavo Barcena on 10/7/14.
//

import UIKit
import ImageIO
import MobileCoreServices

public class GIFResizer: NSObject {
    
    public class func calculateBestNewWidth(oldWidth oldWidth: Int,
        oldSizeInBytes: Int,
        maxSizeInBytes: Int) -> Double {
            let ratioDiff = Double(maxSizeInBytes)/Double(oldSizeInBytes)
            return Double(oldWidth) * ( ratioDiff + ((1-ratioDiff)/3))
    }
    
    public class func resizeGIF(data:NSData, fileURL:NSURL, maxEdgeSize:Double) -> Bool {
        let options = [kCGImageSourceShouldCache as String:false,
            kCGImageSourceTypeIdentifierHint as String:kUTTypeGIF]
        guard let imageSource = CGImageSourceCreateWithData(data, options) else {
            return false
        }
        let numberOfFrames = CGImageSourceGetCount(imageSource)
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, numberOfFrames, nil) else {
            return false
        }
        let fileProperties = [kCGImagePropertyGIFDictionary as String:[kCGImagePropertyGIFLoopCount  as String:0]]
        CGImageDestinationSetProperties(destination, fileProperties)
        
        let newOptions = [kCGImageSourceShouldCache as String:false,
            kCGImageSourceTypeIdentifierHint as String:kUTTypeGIF,
            kCGImageSourceCreateThumbnailFromImageIfAbsent as String:true,
            kCGImageSourceThumbnailMaxPixelSize as String:maxEdgeSize]
        
        for index in 0..<numberOfFrames {
            autoreleasepool {
                let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil)
                if let imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, index, newOptions) {
                    CGImageDestinationAddImage(destination, imageRef, properties)
                }
            }
        }
        
        if (!CGImageDestinationFinalize(destination)) {
            NSLog("failed to finalize image destination");
            return false
        }
        return true
    }
}
