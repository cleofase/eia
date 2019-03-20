//
//  WorkingIndicator.swift
//  Eia
//
//  Created by Cleofas Pereira on 19/03/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit

class WorkingIndicator {
    private var activityIndicator = UIActivityIndicatorView()
    private var baseView = UIView()
    
    public func show(at view: UIView) {
        setupView(for: view)
        view.addSubview(baseView)
        activityIndicator.startAnimating()
    }
    private func setupView(for view: UIView) {
        baseView.frame = view.frame
        baseView.center = view.center
        baseView.backgroundColor = UIColor.clear
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = CGPoint(x: view.frame.width/2 , y: view.frame.height/2)
        activityIndicator.color = EiaColors.PembaSand
        baseView.addSubview(activityIndicator)
    }
    
    public func hide() {
        if activityIndicator.isAnimating {
            DispatchQueue.main.async {[weak self] in
                self?.activityIndicator.stopAnimating()
                self?.baseView.removeFromSuperview()
            }
        }
    }
    
}
