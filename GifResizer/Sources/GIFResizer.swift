//
//  GIFResizer.swift
//
//  Created by Gustavo Barcena on 10/7/14.
//

import UIKit
import ImageIO
import MobileCoreServices

public class GIFResizer: NSObject {
    public class func calculateBestNewWidth(#oldWidth:Int, oldSizeInBytes:Int, maxSizeInBytes:Int) -> Double
    {
        var ratioDiff = Double(maxSizeInBytes)/Double(oldSizeInBytes)
        return Double(oldWidth) * ( ratioDiff + ((1-ratioDiff)/3))
    }
    
    public class func resizeGIF(data:NSData, fileURL:NSURL, maxEdgeSize:Double) -> Bool
    {
        var options = [kCGImageSourceShouldCache as String:false,
            kCGImageSourceTypeIdentifierHint as String:kUTTypeGIF]
        var imageSource = CGImageSourceCreateWithData(data, options)
        var numberOfFrames = CGImageSourceGetCount(imageSource)
        
        var destination = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, numberOfFrames, nil);
        var fileProperties = [kCGImagePropertyGIFDictionary as String:[kCGImagePropertyGIFLoopCount  as String:0]]
        CGImageDestinationSetProperties(destination, fileProperties)
        
        var newOptions = [kCGImageSourceShouldCache as String:false,
            kCGImageSourceTypeIdentifierHint as String:kUTTypeGIF,
            kCGImageSourceCreateThumbnailFromImageIfAbsent as String:true,
            kCGImageSourceThumbnailMaxPixelSize as String:maxEdgeSize]
        
        for index in 0..<numberOfFrames
        {
            autoreleasepool {
                var imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, index, newOptions)
                var properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil)
                CGImageDestinationAddImage(destination, imageRef, properties)
            }
        }
        
        if (!CGImageDestinationFinalize(destination)) {
            NSLog("failed to finalize image destination");
            return false
        }
        return true
    }
}
