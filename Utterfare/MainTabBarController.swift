//
//  CustomTabBarController.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/25/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate{
    let defaults = UserDefaults.standard
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let isLoggedIn = defaults.bool(forKey: "IS_LOGGED_IN")
        if !isLoggedIn{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
}
