//
//  ViewController.swift
//  CameraPractice
//
//  Created by Ada on 1/8/18.
//  Copyright © 2018 yuxujian. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    
    var catureSession = AVCaptureSession()
    
    @IBAction func cameraButton_TouchUpInside(_ sender: UIButton) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputputOutput()
        setupPreviewLayer()
        startRuningCatureSession()
    }
    
    func setupCaptureSession() {
        catureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        
    }
    
    func setupInputputOutput() {
        
    }
    
    func setupPreviewLayer() {
        
    }
    
    func startRuningCatureSession() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

