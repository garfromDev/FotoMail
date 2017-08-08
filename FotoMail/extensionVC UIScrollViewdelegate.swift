//
//  extensionViewController.swift
//  FotoMail
//
//  Created by Alistef on 22/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//
//-----------------------------------------------------
// Copied from testScroolViewPlusTransparent 05/08/2017
//-----------------------------------------------------

import UIKit

extension ViewController : UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView)
    {
        clrView.setNeedsDisplay() //il faut remettre à jour la vue transparente avec le bon niveau de zoom
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        clrView.setNeedsDisplay() //il faut remettre à jour la vue transparente avec le bon décalage
    }
    
    
//    open override func viewDidLayoutSubviews() {
//        print("viewDidLayoutSubviews() \(scrollView.bounds)")
//        super.viewWillLayoutSubviews()
//        updateMinZoomScaleForSize(scrollView.bounds.size) //le niveau de zoom mini peut être différent en portrait ou en paysage
//    }
//    
//    
    func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.height / imageView.bounds.width
        let heightScale = size.width / imageView.bounds.height
        let minScale = max(widthScale, heightScale) //on choisi de toujours remplir l'écran, un peu de l'image sera en dehors si le ratio n'est pas le même
        var newScale = minScale
        let oldMinScale = scrollView.minimumZoomScale
        let currentScale = scrollView.zoomScale
        // si l'utilisateur avait déjà zoomé, on tente de garder le même niveau de zoom
        if (oldMinScale > 0 && oldMinScale < 1 ){
            newScale = 1 - (1 - currentScale) / (1 - oldMinScale) * ( 1 - minScale)
        }
        scrollView.minimumZoomScale = minScale
        //        print("updateMinZoomScaleForSize \(size) oldMin \(oldMinScale)  min \(minScale)  actuel \(scrollView.zoomScale) new \(newScale)")
        scrollView.zoomScale = newScale
    }
    
    
    
}
