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
        // principe : la imageView qui contient l'image est zoomée
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
        print("updateMinZoomScaleForSize  \(size)  imageViewBounds \(imageView.bounds) oldminscale \(scrollView.minimumZoomScale) oldscale \(scrollView.zoomScale)")
        guard imageView.bounds.width > 0 && imageView.bounds.height > 0 else { return }
        let widthScale : CGFloat = size.width / imageView.bounds.width
        let heightScale : CGFloat = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        var newScale = minScale
        let oldMinScale = scrollView.minimumZoomScale
        let currentScale = scrollView.zoomScale
        // on ne conserve pas le niveau de zoom si c'est le premier calcul
        if (oldMinScale > 0 && oldMinScale < 1 && currentScale < 1.0){
            // on réajuste le niveau de zoom pour tenir compte de l'écart de taille et donc des nouvelles bornes de zoom
            newScale = 1 - ( (1 - currentScale) / (1 - oldMinScale) ) * ( 1 - minScale)
        }
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = newScale
        print("did set minimumZoomScale : \(minScale)  zommScale : \(newScale)")
    }
    
    
    // to center correctlythe image when zoomed with one dimension less that scrollView size
     func updateConstraintsForSize(size: CGSize)
    {
        print("update constraint size : \(size) imageView.frame : \(imageView.frame.size) scrollview.bounds \(scrollView.bounds.size)")
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
        print("xOffset : \(xOffset)  yOffset : \(yOffset)")
        view.layoutIfNeeded()
    }
    
    // TODO: voir si reellement utile
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("viewWillTransition(to size: \(size)")
        updateConstraintsForSize(size: size)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    }
