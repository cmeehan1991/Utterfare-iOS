//
//  CustomViews.swift
//  Utterfare
//
//  Created by Connor Meehan on 12/19/19.
//  Copyright © 2019 Utterfare. All rights reserved.
//

import Foundation
import UIKit

class CustomViews: UIViewController{
    
    func loadingIndicatorView(viewController: UIView) -> UIActivityIndicatorView{
        let loadingIndicator : UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge) as UIActivityIndicatorView
        loadingIndicator.center = view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        loadingIndicator.startAnimating()
        
        return loadingIndicator
    }
}
