//
//  ViewController.swift
//  doodle grid client
//
//  Created by Vito Genovese on 8/6/18.
//  Copyright © 2018 Vito Genovese. All rights reserved.
//

import UIKit
import os.log
import SwiftSocket

class ViewController: UIViewController
{
    //MARK: Properties
    @IBOutlet weak var fgColor: UILabel!
    @IBOutlet weak var drawCanvas: DoodleView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var bgColor: UILabel!
    @IBOutlet weak var destinationField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sliderValueChanged(self)
        fgColor.backgroundColor = drawCanvas.penColor
        bgColor.backgroundColor = drawCanvas.bgColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sliderValueChanged(_ sender: Any) {
        let newColor = UIColor(red: CGFloat(redSlider.value),
                               green: CGFloat(greenSlider.value),
                               blue: CGFloat(blueSlider.value),
                               alpha: 1.0)
        
        fgColor.backgroundColor = newColor
        drawCanvas.penColor = newColor
    }

    @IBAction func sendImage(_ sender: Any) {
        var pixelBuf = drawCanvas.pixelBuf
 
       let sock = UDPClient(address: destinationField.text!, port: 27420)
        
        var netBuf = [UInt8](repeating: 0, count: 512)
        netBuf.removeAll(keepingCapacity: true)
        var netCount: UInt8 = 0
        
        for y in 0..<16 {
            for x in 0..<16 {
                let idx = drawCanvas.bufBytesPerPixel * (x + (y * 16))
                netBuf.append(UInt8(x))
                netBuf.append(UInt8(y))
                netBuf.append(pixelBuf[idx + 0])
                netBuf.append(pixelBuf[idx + 1])
                netBuf.append(pixelBuf[idx + 2])
                
                netCount += 1
                
                if netBuf.count > 500 {
                    netBuf.insert(netCount, at: 0)
                    
                    let _ = sock.send(data: netBuf)
                    
                    netCount = 0
                    netBuf.removeAll(keepingCapacity: true)
                }
                
            }
        }
        
        
        netBuf.insert(netCount, at: 0)
        
        let _ = sock.send(data: netBuf)
        
        
    }
    @IBAction func updateBgColor(_ sender: Any) {
        let oldBg = drawCanvas.bgColor
        drawCanvas.bgColor = drawCanvas.penColor
        bgColor.backgroundColor = drawCanvas.penColor
        
        drawCanvas.penColor = oldBg
        fgColor.backgroundColor = oldBg
    }
    
    @IBAction func undoLasttouch(_ sender: Any) {
        drawCanvas.cancelLastDraw()
    }
    @IBAction func blackPreset(_ sender: Any) {
        let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        drawCanvas.bgColor = black
        bgColor.backgroundColor = black
    }
    @IBAction func clearImage(_ sender: Any) {
        drawCanvas.clear()
    }
    
}

