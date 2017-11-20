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
    
    
    
    
}
