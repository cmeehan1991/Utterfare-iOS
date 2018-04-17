//
//  CustomCodeField.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/12/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//
//http://www.globalnerdy.com/2016/05/24/a-better-way-to-program-ios-text-fields-that-have-maximum-lengths-and-accept-or-reject-specific-characters/

import UIKit

private var maxLengths = [UITextField: Int]()

extension UITextField{
    @IBInspectable var maxLength: Int{
        get{
            guard let length = maxLengths[self] else{
                return Int.max
            }
            return length
        }
        set{
            maxLengths[self] = newValue
            addTarget(self, action: #selector(limitLength), for: .editingChanged)
        }
    }
    
    @objc func limitLength(textField: UITextField){
        guard let prospectiveText = textField.text, prospectiveText.count > maxLength else{
            return
        }
        let selection = selectedTextRange
        text = String(prospectiveText[prospectiveText.startIndex ..< prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)])
        
        selectedTextRange = selection
    }
}
