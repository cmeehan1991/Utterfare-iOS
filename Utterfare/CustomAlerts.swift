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
    
    private func alertActivity(alert: UIAlertController) -> UIActivityIndicatorView{
        let activity: UIActivityIndicatorView = UIActivityIndicatorView(frame: alert.view.bounds)
        activity.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activity.startAnimating()
        return activity
    }
    
    func loadingAlert(title: String, message: String)->UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let activity = alertActivity(alert: alert)
        alert.view.addSubview(activity)
        
        return alert
    }
    
    
    func errorAlert(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(dismissAction)
        
        return alert
    }
    
}
