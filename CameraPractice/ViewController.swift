//
//  ViewController.swift
//  CameraPractice
//
//  Created by Ada on 1/8/18.
//  Copyright © 2018 yuxujian. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController,AVCapturePhotoCaptureDelegate {
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image:UIImage?
    
    var toggleCameraGestureRecognizer = UISwipeGestureRecognizer()
    
    var zoomInGestureRecognizer = UISwipeGestureRecognizer()
    var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBAction func cameraButton_TouchUpInside(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        //Initiates a photo capture using the specified settings
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputputOutput()
        setupPreviewLayer()
        startRuningCatureSession()
        
        toggleCameraGestureRecognizer.direction = .up
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(self.switchCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        // Zoom In recognizer
        zoomInGestureRecognizer.direction = .right
        zoomInGestureRecognizer.addTarget(self, action: #selector(zoomIn))
        view.addGestureRecognizer(zoomInGestureRecognizer)
        
        // Zoom Out recognizer
        zoomOutGestureRecognizer.direction = .left
        zoomOutGestureRecognizer.addTarget(self, action: #selector(zoomOut))
        view.addGestureRecognizer(zoomOutGestureRecognizer)
        styleCaptureButton()
    }
    
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
    
    func setupCaptureSession() {
        //taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
    }
    
    func setupDevice() {
        //find all available capture devices(也就所有iphone机型)
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        //find the camera devices for taking photos (front camera or back camera)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        //default use back camera
        currentDevice = backCamera
        
    }
    
    func setupInputputOutput() {
        //create capture device input
        do {
            //A capture input that provides media from a capture device to a capture session.
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            
            //DeviceInput add to Session
            captureSession.addInput(captureDeviceInput)
            
            //create capture output
            photoOutput = AVCapturePhotoOutput()
            
            //Tells the photo capture output to prepare resources for future capture requests with the specified settings
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            
            captureSession.addOutput(photoOutput!)
            
        } catch  {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        //create preview layer and start the session
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //Indicates how the video is displayed within a player layer’s bounds rect.
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        //The orientation of the video.
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        //display full screen
        cameraPreviewLayer?.frame = self.view.frame
        
        //inport "cameraPreviewLayer" property to view layer
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    
    func startRuningCatureSession() {
        //Tells the receiver to start running.
        captureSession.startRunning()
    }
    
    //prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto_Segue" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = self.image
        }
    }
    
    //Provides the delegate with the captured image and associated metadata resulting from a photo capture.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            
            //convert data to image
            image = UIImage(data: imageData)
            
            //go to PreviewViewController
            performSegue(withIdentifier: "showPhoto_Segue", sender: nil)
        }
    }
    
    
    @objc func switchCamera() {
        captureSession.beginConfiguration()
        
        // Change the device based on the current camera
        let newDevice = (currentDevice?.position == AVCaptureDevice.Position.back) ? frontCamera : backCamera
        
        // Remove all inputs from the session
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        // Change to the new input
        let cameraInput:AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch {
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    @objc func zoomIn() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor < 5.0 {
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @objc func zoomOut() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor > 1.0 {
                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
}

//extension ViewController: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let imageData = photo.fileDataRepresentation() {
//            image = UIImage(data: imageData)
//            performSegue(withIdentifier: "showPhoto_Segue", sender: nil)
//        }
//    }
//}

