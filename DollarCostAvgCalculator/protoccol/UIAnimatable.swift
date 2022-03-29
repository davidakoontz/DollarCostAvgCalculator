//
//  UIAnimatable.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/25/22.
//

import Foundation
import MBProgressHUD

protocol UIAnimatable where Self:  UIViewController {
    func showLoadingAnimation()     // spinner animation
    func hideLoadingAnimation()
}

extension UIAnimatable {
    
    func showLoadingAnimation()  {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    func hideLoadingAnimation() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
        
}
