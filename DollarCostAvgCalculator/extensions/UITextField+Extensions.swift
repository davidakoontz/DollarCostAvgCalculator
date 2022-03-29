//
//  UITextField+Extensions.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/26/22.
//

import Foundation
import UIKit

extension UITextField {
    func addDoneButton()  {
        let screenWidth = UIScreen.main.bounds.width
        let doneToolBar: UIToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: screenWidth, height: 50))
    
        doneToolBar.barStyle = .default
        let flexBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector( dismissKeyboard ))
        let items  = [flexBarButtonItem, doneBarButtonItem]
        
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        
        inputAccessoryView = doneToolBar
    }
    
    // the action of the Done Button  we made.
    @objc private func  dismissKeyboard() {
        resignFirstResponder()
    }
}
