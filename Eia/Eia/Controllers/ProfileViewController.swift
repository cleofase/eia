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
    
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    private var handle: AuthStateDidChangeListenerHandle?

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
        handle = Auth.auth().addStateDidChangeListener({[weak self] (auth, user) in
            guard let _ = user else {
                self?.goToLoginScreen()
                return
            }
            self?.updateUI()
        })
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
    private func goToLoginScreen() {
        let mainStoryBorad = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = mainStoryBorad.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initialViewController
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
        let context = containter.viewContext
        let voluntaryId = Auth.auth().currentUser?.uid ?? ""
        if voluntary == nil {
            voluntary = Voluntary.find(matching: voluntaryId, in: context)
        }
        guard let voluntary = voluntary else {
            retrieveVoluntaryFromCloud(withVoluntaryId: voluntaryId, completionWithSuccess: {[weak self] in
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            })
            return
        }
        nameLabel.text = "\(voluntary.name ?? "") - \(voluntary.status ?? "")"
        emailLabel.text = voluntary.email
        phoneLabel.text = voluntary.phone
        if let photoStr = voluntary.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            photoImageView.image = photoImage
        } else {
            // photo default...
        }
    }
    private func retrieveVoluntaryFromCloud(withVoluntaryId voluntaryId: String, completionWithSuccess: @escaping () -> Void) {
        let context = containter.viewContext
        fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            if let voluntaryDic = snapshot.value as? NSDictionary {
                DispatchQueue.main.async {
                    self?.voluntary = Voluntary.createOrUpdate(matchDictionary: voluntaryDic, in: context)
                    try? context.save()
                    completionWithSuccess()
                }
            }
        })
    
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
