//
//  ViewController.swift
//  sniper
//
//  Created by Ali Korabbaslu on 4/9/16.
//  Copyright © 2016 Ali Korabbaslu. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    
    @IBOutlet weak var panda: UIImageView!
    let stillImageOutput = AVCaptureStillImageOutput()
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        if captureDevice != nil {
            beginSession()
        }
        
    }
    func beginSession() {
        
        do {
            configureDevice()
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.view.layer.addSublayer(previewLayer!)
            previewLayer?.frame = self.view.layer.frame
            panda.clipsToBounds = true
            self.view.addSubview(panda)
            captureSession.startRunning()
        }
        catch {
            //TODO: handle error here!
            
        }
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                UIImageWriteToSavedPhotosAlbum(self.mergeImages(UIImage(data: imageData)!), nil, nil, nil)
            }
        }
    }
    
    func mergeImages(bottomImage: UIImage) -> UIImage {
        let size =  CGSize(width: 800, height: 1200)
        UIGraphicsBeginImageContext(size)
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bottomImage.drawInRect(areaSize)
        panda.image!.drawInRect(panda.frame, blendMode: CGBlendMode.Normal, alpha: 1)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                //device.focusMode = .ContinuousAutoFocus
                device.unlockForConfiguration()
            }
            catch {
                
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}

