//
//  ImageScrollViewController.swift
//  Smashtag
//
//  Created by Raphael on 3/22/16.
//  Copyright © 2016 Skyleaf Design. All rights reserved.
//

import UIKit

class ImageScrollViewController: UIViewController, UIScrollViewDelegate {
    
    
    
    // MARK: Initialize outlets, set delegates, etc.
    
    private var imageView = UIImageView()
    
    private var notificationCenter = NSNotificationCenter.defaultCenter()
    
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
        }
    }

    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
        }
    }
    
    
    
    // MARK: Private internal methods and properties.
    
    @objc private func zoomToImageWidth() {
        // @todo: only do this if the user hasn't zoomed via gesture.
        
        // Set the minimum zoom scale, so that the image cannot be zoomed smaller than the screen width.
        let scaleWidth = scrollView.bounds.size.width / imageView.bounds.size.width
        scrollView.minimumZoomScale = scaleWidth
        
        
        // Zoom to fit the width; we dont' care about the height.
        let zoomSize = CGSize(width: imageView.bounds.size.width, height: CGFloat(0))
        
        // Why does the image start at the bottom of the screen?
        scrollView.zoomToRect(CGRect(origin: CGPoint(x: CGFloat(0), y: CGFloat(0)), size: zoomSize), animated: true)
    }
    
    
    
    // MARK: ViewController life cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView!.contentSize = imageView.frame.size
        scrollView.addSubview(imageView)
        
        // Zoom in when the device is rotated.
        notificationCenter.addObserver(self, selector: #selector(self.zoomToImageWidth), name: "UIDeviceOrientationDidChangeNotification", object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // Set the maximum zoom scale, which is always fixed at 2.0.
        scrollView.maximumZoomScale = 2.0
        
        zoomToImageWidth()
    }
    
    
    
    // MARK: UIScrollViewDelegate implementation.
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
