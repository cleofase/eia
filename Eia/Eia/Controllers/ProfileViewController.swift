//
//  ProfileViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 25/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var photoBackgroundView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBAction func manageButton(_ sender: UIBarButtonItem) {
        manageProfile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Do any additional setup after loading the view.
    }
    private func setupUI() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = photoBackgroundView.bounds
        gradientLayer.colors = [EiaColors.PembaSand.cgColor, UIColor.white.cgColor]
        photoBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        photoImageView.layer.cornerRadius = photoImageView.frame.height/2
        photoImageView.clipsToBounds = true
    }
    private func manageProfile() {
        let manageAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        manageAlert.addAction(UIAlertAction(title: "Editar", style: .default, handler: {[weak self] (_) in
            self?.editProfile()
        }))
        manageAlert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: {[weak self] (_) in
            self?.performLogout()
        }))
        manageAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(manageAlert, animated: true, completion: nil)
    }
    private func performLogout() {
        
    }
    private func editProfile() {
        performSegue(withIdentifier: "editProfileSegue", sender: self)
    }
}
