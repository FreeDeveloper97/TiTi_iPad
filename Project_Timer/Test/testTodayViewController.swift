//
//  testTodayViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/07/10.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit

class testTodayViewController: UIViewController {

    @IBOutlet var frame: UIView!
    @IBOutlet var innerView: UIView!
    
    @IBOutlet var selectDayBT: UIButton!
    @IBOutlet var selectDay: UILabel!
    @IBOutlet var selectDayBgView: UIView!
    
    var staticHeight: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setRadius()
        setShadow(innerView)
        setShadowDayBgView()
//        selectDay.text = "Today"
        selectDay.text = "2021.07.11"
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        saveImage(view)
        showAlert()
    }
}


extension testTodayViewController {
    
    func setRadius() {
        innerView.layer.cornerRadius = 25
        selectDayBgView.layer.cornerRadius = 12
    }
    
    func setShadow(_ view: UIView) {
        view.layer.shadowColor = UIColor(named: "shadow")?.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 5
    }
    
    func setShadowDayBgView() {
        selectDayBgView.layer.masksToBounds = false
//        selectDayBgView.layer.shadowColor = todayViewManager.COLOR.cgColor
        selectDayBgView.layer.shadowColor = UIColor(named: "D1")?.cgColor
        selectDayBgView.layer.shadowOpacity = 0.5
        selectDayBgView.layer.shadowOffset = CGSize.zero
        selectDayBgView.layer.shadowRadius = 5.5
        
//        selectDay.layer.shadowColor = todayViewManager.COLOR.cgColor
        selectDay.layer.shadowColor = UIColor(named: "D1")?.cgColor
        selectDay.layer.shadowOpacity = 1
        selectDay.layer.shadowOffset = CGSize(width: 1, height: 0.5)
        selectDay.layer.shadowRadius = 1.5
    }
    
    func showAlert() {
        let alert = UIAlertController(title:"Save completed".localized(),
            message: "",
            preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func saveImage(_ getFrame: UIView) {
        let width: Double = Double(getFrame.bounds.width)
        let height: Double = Double(getFrame.bounds.height)
        let img = UIImage.init(view: getFrame)
        if(height > width) {
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        } else {
            let rectImg = cropToBounds(image: img, width: width, height: height)
            UIImageWriteToSavedPhotosAlbum(rectImg, nil, nil, nil)
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {

            let cgimage = image.cgImage!
            let contextImage: UIImage = UIImage(cgImage: cgimage)
            let contextSize: CGSize = contextImage.size
            var posX: CGFloat = 0.0
            var posY: CGFloat = 0.0
            var cgwidth: CGFloat = CGFloat(width)
            var cgheight: CGFloat = CGFloat(height)

            // See what size is longer and create the center off of that
            if contextSize.width > contextSize.height {
                posX = ((contextSize.width - contextSize.height) / 2)
                posY = 0
                cgwidth = contextSize.height
                cgheight = contextSize.height
            } else {
                posX = 0
                posY = ((contextSize.height - contextSize.width) / 2)
                cgwidth = contextSize.width
                cgheight = contextSize.width
            }

            let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

            // Create bitmap image from context using the rect
            let imageRef: CGImage = cgimage.cropping(to: rect)!

            // Create a new image based on the imageRef and rotate back to the original orientation
            let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

            return image
        }
}
