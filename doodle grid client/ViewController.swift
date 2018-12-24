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
        for y in 0..<16 {
            for x in 0..<16 {
                let idx = drawCanvas.bufBytesPerPixel * (y + (x * 16))
                let r = UInt16(pixelBuf[idx + 0] >> 4)
                let g = UInt16(pixelBuf[idx + 1] >> 4)
                let b = UInt16(pixelBuf[idx + 2] >> 4)

                let val = (b << (4 + 4)) +
                          (g << (4)) +
                          (r)

                let msb = UInt8(val >> 8)
                let lsb = UInt8(val & 0xFF)
                
                netBuf.append(lsb)
                netBuf.append(msb)
                
                
            }
        }
        
        
        
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

