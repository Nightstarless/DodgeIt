//
//  GameViewController.swift
//  Dodgeit
//
//  Created by YuankaiLiu on 12/1/18.
//  Copyright © 2018 YuankaiLiu. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreML
import AVKit

class GameViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate{
   
    var captureSession : AVCaptureSession!
    var modelcnn = cnn1()
    var previewLayer : AVCaptureVideoPreviewLayer!
    var ges : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            self.ges = "rock"
            // Load the SKScene from 'GameScene.sks'
            captureSession = AVCaptureSession()
            guard let captureDevice = AVCaptureDevice.default(for: .video) else{
                return}
            guard let input = try?AVCaptureDeviceInput(device:captureDevice)else{
                return}
            captureSession.addInput(input)
            captureSession.startRunning()
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            let videoFrame = AVCaptureVideoDataOutput()
            self.view.layer.addSublayer(previewLayer)
            //previewLayer.position = CGPoint(x: CGFloat(100),y:CGFloat(50))
            previewLayer.frame = CGRect(x: CGFloat(364) , y: CGFloat(-100), width: CGFloat(50), height:CGFloat(300))
            //print(previewLayer.position)
            videoFrame.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoFrame"))
            captureSession.addOutput(videoFrame)
            
            
            if let scene = StartScene (fileNamed: "StartScene") {
                // Set the scale mode to scale to fit the window
                scene.size = CGSize(width: 748,height:1344)
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func convert(cmage:CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int)
    {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = imageRef {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            let totalBytes = height * bytesPerRow
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            var intensities = [UInt8](repeating: 0, count: totalBytes)
            
            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            pixelValues = intensities
        }
        return (pixelValues, width, height)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let ciimage : CIImage = CIImage(cvPixelBuffer: cvPixelBuffer)
        let image : UIImage = self.convert(cmage: ciimage)
        let image2 = image.resizeImage()
        let pixelBuffer = image2.pixelBuffer()
        let outputcnn = try? modelcnn.prediction(image: pixelBuffer!)
        DispatchQueue.main.async {
            //            self.predictionLabel.text = outputRf.classLabel
            let keyMaxElement = outputcnn?.output1.max(by: { (a, b) -> Bool in
                return a.value < b.value
            })
        
        UserDefaults.standard.set(keyMaxElement?.key, forKey: "GESTURE")
//            switch ges{
//            case "right" :
//                self.xAcceleration = 1
//            case "left" :
//                self.xAcceleration = -1
//            case "five":
//                self.bomb()
//            case "rock":
//                self.xAcceleration = 0
//            default :
//                break
//            }
            //print(outputcnn?.output1)
        }
        
    }
}
