//
//  DoodleView.swift
//  doodle grid client
//
//  Created by Vito Genovese on 8/7/18.
//  Copyright © 2018 Vito Genovese. All rights reserved.
//

import UIKit
import os.log

class DoodleView: UIImageView {
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var cleanImage: UIImage?
    var cleanBuf: [UInt8]?
    var penColor: UIColor = UIColor.red
    var bgColor: UIColor = UIColor.red
    var pixelBuf: [UInt8] = []
    let destImageSize = CGSize(width: 16, height: 16)
    let bufBytesPerPixel = 3
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pixelBuf = [UInt8](repeating: 0, count:
            (Int)(destImageSize.width) *
            (Int)(destImageSize.height) *
            bufBytesPerPixel)
    }
    
    func clear() {
        let i = self.image!
        
        let r = (UInt8)(255 * bgColor.cgColor.components![0])
        let g = (UInt8)(255 * bgColor.cgColor.components![1])
        let b = (UInt8)(255 * bgColor.cgColor.components![2])
        
        for y in 0..<((Int)(destImageSize.width)) {
            for x in 0..<((Int)(destImageSize.height)) {
                let idx = bufBytesPerPixel * (x + (y * 16))
                pixelBuf[idx] = r
                pixelBuf[idx + 1] = g
                pixelBuf[idx + 2] = b
            }
        }
        
        UIGraphicsBeginImageContext(i.size)
        i.draw(at: CGPoint.zero)
        bgColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: i.size))
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        cleanImage = UIImage(cgImage: self.image!.cgImage!)
        cleanBuf = [UInt8](pixelBuf)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let i = self.image!
        UIGraphicsBeginImageContext(i.size)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.interpolationQuality = .none
        
        i.draw(at: CGPoint.zero)
        penColor.setFill()
        
        let scale = (Int)(frame.size.width / destImageSize.width)
        
        let uiScale = (Int)(i.size.width / frame.size.width)
        
        let r = (UInt8)(255 * penColor.cgColor.components![0])
        let g = (UInt8)(255 * penColor.cgColor.components![1])
        let b = (UInt8)(255 * penColor.cgColor.components![2])
        
        for t in touches {
            let loc = t.location(in: self)
            
            let x_loc = Int(loc.x)
            let y_loc = Int(loc.y)
            
            let x_idx = x_loc / scale
            let y_idx = (y_loc / scale) * 16
            
            let idx = bufBytesPerPixel * (x_idx + y_idx)
            
            if idx >= pixelBuf.count {
                continue
            }
            
            pixelBuf[idx] = r
            pixelBuf[idx + 1] = g
            pixelBuf[idx + 2] = b
            
            let scaleMod = scale * uiScale
            
            let uiX = (uiScale * x_loc) - ((uiScale * x_loc) % scaleMod)
            let uiY = (uiScale * y_loc) - ((uiScale * y_loc) % scaleMod)
            
            let rect = CGRect(x: uiX,
                              y: uiY,
                              width: scale * uiScale,
                              height: scale * uiScale)
            UIRectFill(rect)
        }
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelLastDraw()
    }
    
    func cancelLastDraw() {
        self.image = cleanImage
        self.pixelBuf = cleanBuf!
    }
}
