//
//  ViewController.swift
//  GifResizer
//
//  Created by Gustavo Barcena on 5/27/15.
//  Copyright (c) 2015 Gustavo Barcena. All rights reserved.
//

import UIKit
import GifWriter
import YLGIFImage

func runOnMainThread(block:()->()) {
    dispatch_async(dispatch_get_main_queue()) {
        block()
    }
}

func stringFromSize(size:CGSize?) -> String {
    if let size = size {
        return "\(size.width)x\(size.height)"
    }
    return ""
}

class ViewController: UIViewController {
    @IBOutlet weak var imageView : YLImageView!
    @IBOutlet weak var label : UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.writeGIF()
        }
    }
    
    func writeGIF() {
        var images = [UIImage]()
        for i in 1...7 {
            let imageName = "ninenine_\(i)"
            if let image = UIImage(named: imageName) {
                images.append(image)
            }
        }
        let fileURL = self.dynamicType.fileLocation("ninenine.gif")
        guard let gifWriter = GIFWriter(images: images) else {
            return
        }
        gifWriter.makeGIF(fileURL)
        
        guard let
            data = NSData(contentsOfURL: fileURL),
            gifImage = YLGIFImage(data: data) else
        {
            return
        }
        runOnMainThread({ () -> () in
            self.imageView.image = gifImage
            self.label.text = "Created GIF \(stringFromSize(gifImage.size))"
        })
        
        NSThread.sleepForTimeInterval(1.0)
        
        let maxSize = 300000
        let size = gifImage.size
        print("Original Size: \(data.length)")
        print("Original Width: \(size.width)")
        
        let newWidth = GIFResizer.calculateBestNewWidth(oldWidth: Int(size.width),
            oldSizeInBytes: data.length,
            maxSizeInBytes: maxSize)
        print("newWidth Width: \(newWidth)")
        
        let maxEdgeSize: Double
        if size.width >= size.height {
            maxEdgeSize = newWidth
        }
        else {
            maxEdgeSize = newWidth * Double(size.height / size.width)
        }
        
        let smallFileURL = self.dynamicType.fileLocation("ninenine-small.gif")
        let success = GIFResizer.resizeGIF(data, fileURL: smallFileURL, maxEdgeSize: maxEdgeSize)
        if (success) {
            if let data = NSData(contentsOfURL: smallFileURL) {
                let gifImage = YLGIFImage(data: data)
                runOnMainThread {
                    self.imageView.image = gifImage
                    self.label.text = "Resized GIF \(stringFromSize(gifImage?.size))"
                }
                print("Final Size: \(data.length)")
                print("Final Width: \(gifImage!.size.width)")
            }
        }
        
    }
    
    class func fileLocation(fileName:String) -> NSURL {
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = path.URLByAppendingPathComponent(fileName)
        return fileURL
    }
}
