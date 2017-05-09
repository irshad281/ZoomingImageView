//
//  ViewController.swift
//  ZoomingImageView
//
//  Created by preeti rani on 09/05/17.
//  Copyright © 2017 Innotical. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(tap:))))
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    var tapImageView:UIImageView?
    var blurEffectView:UIVisualEffectView?
    func handleTap(tap:UITapGestureRecognizer){
        print("TAP ON IMAGE......")
        if let imageView = tap.view as? UIImageView{
            self.imageView.isHidden = true
            let frame = imageView.superview?.convert(imageView.frame, from: self.view)
            if let keyWindow = UIApplication.shared.keyWindow{
                let height = keyWindow.bounds.width * (frame?.height)! / (frame?.width)!
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
                
                blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView?.frame = view.bounds
                blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blurEffectView?.alpha = 0
                keyWindow.addSubview(blurEffectView!)
                let copyImage = UIImageView.init(frame: imageView.bounds)
                tapImageView = copyImage
                copyImage.isUserInteractionEnabled = true
                copyImage.image = imageView.image
                copyImage.center = imageView.center
                copyImage.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(_:))))
                keyWindow.addSubview(copyImage)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    copyImage.frame = CGRect.init(x: 0, y: 0, width: keyWindow.bounds.width, height: height)
                    copyImage.center = keyWindow.center
                    self.blurEffectView?.alpha = 1
                }, completion: nil)
            }
        }
    }
    
    
    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            
        }else if gestureRecognizer.state == .ended{
            if let yPosition = gestureRecognizer.view?.center.y{
                print("Y Position ",yPosition)
                let maxUpperpoint = self.view.frame.height/2 -  self.view.frame.height/4
                let maxDownpoint = self.view.frame.height -  self.view.frame.height/4
                if yPosition >= maxDownpoint{
                    dismissZoom()
                }else if maxUpperpoint >= yPosition{
                    dismissZoom()
                }else{
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        self.tapImageView?.center = self.view.center
                    }, completion: { (success) in
                    })
                }
            }
        }
    }
    
    
    func dismissZoom(){
        print("Dismiss Image........")
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity:0.5, options: .curveEaseOut, animations: {
            self.tapImageView?.frame = self.imageView.frame
            self.tapImageView?.center = self.imageView.center
            self.tapImageView?.layer.cornerRadius = 15
            self.tapImageView?.clipsToBounds = true
        }, completion: { (success) in
            self.blurEffectView?.alpha = 0
            self.imageView.isHidden = false
            self.tapImageView?.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
        })
    }
    
}

