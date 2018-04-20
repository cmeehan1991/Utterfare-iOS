//
//  CustomAlerts.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/6/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation
import UIKit

class CustomAlerts: UIAlertController{
    var loadingView : UIView = UIView()
    
    private func alertActivity(view: UIView) -> UIActivityIndicatorView{
        let activity: UIActivityIndicatorView = UIActivityIndicatorView()
        activity.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activity.activityIndicatorViewStyle = .whiteLarge
        activity.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        return activity
    }
    
    func loadingAlert(uiView: UIView)->UIView{
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        loadingView.addSubview(alertActivity(view: loadingView))
        
        return loadingView
    }
    
    
    func successAlert(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(dismissAction)
        
        return alert
    }
    
    func errorAlert(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(dismissAction)
        
        return alert
    }
    
}
