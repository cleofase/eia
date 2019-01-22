//
//  ProfileViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 25/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    public var voluntary: Voluntary?
    
    @IBOutlet weak var photoBackgroundView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBAction func manageButton(_ sender: UIBarButtonItem) {
        manageProfile()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProfileSegue" {
            if let destination = segue.destination as? EditProfileTableViewController {
                destination.voluntary = voluntary
            }
        }
    }
    private func setupUI() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = photoBackgroundView.bounds
        gradientLayer.colors = [EiaColors.PembaSand.cgColor, UIColor.white.cgColor]
        photoBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        photoImageView.layer.cornerRadius = photoImageView.frame.height/2
        photoImageView.clipsToBounds = true
    }
    private func updateUI() {
        guard let voluntary = voluntary else {return}
        nameLabel.text = "\(voluntary.name ?? "") - \(voluntary.status ?? "")"
        emailLabel.text = voluntary.email
        phoneLabel.text = voluntary.phone
        if let photoStr = voluntary.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            photoImageView.image = photoImage
        } else {
            // photo default...
        }
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
        try? Auth.auth().signOut()
    }
    private func editProfile() {
        performSegue(withIdentifier: "editProfileSegue", sender: self)
    }
}
