//
//  extensionViewController.swift
//  FotoMail
//
//  Created by Alistef on 22/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit

extension ViewController : UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("scrollViewDidZoom newSize (w/h) \(scrollView.bounds.size)")
        updateConstraintsForSize(size: self.view.bounds.size)
    }

    /*
    pourrais être utilisé pour préparer le dessin en tache de fond, sans attendre la 1ere touche sur l'écran
     mais il faut que ça se passe en background, car sinon sur la main thread le scrolling n'est pas fluide
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        self.imageView.prepareEditing()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("scrollViewDidEndZooming")
        self.imageView.prepareEditing()
    }
 
 */
    
    //---------------------------------------------------------------------------------
    // ne fait pas parti du protocole, fonctions helper pour adapter le niveau de zoom
    
    func updateMinZoomScaleForSize(_ size: CGSize)
    {
        print("updateMinZoomScaleForSize")
        let widthScale : CGFloat = size.width / imageView.bounds.width
        let heightScale : CGFloat = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    
    // to center correctlythe image when zoomed with one dimension less that scrollView size
     func updateConstraintsForSize(size: CGSize)
    {
        print("update constraint imageView.frame : \(imageView.frame.size) scrollview.bounds \(scrollView.bounds.size)")
        let yOffset = max(0, (size.height
            - previewTitreTextField.bounds.size.height
            - previewToolbar.bounds.size.height
            - 16
            - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
//        drawingViewTopConstraint.constant = yOffset
//        drawingViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - 16 - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
//        drawingViewLeadingContraint.constant = xOffset
//        drawingViewTrailingConstraint.constant = xOffset
        view.layoutIfNeeded()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("viewWillTransition(to size: \(size)")
        updateConstraintsForSize(size: size)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    }
