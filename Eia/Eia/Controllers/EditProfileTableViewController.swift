//
//  EditProfileTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 26/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit
import Photos
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class EditProfileTableViewController: EiaFormTableViewController {
    public var voluntary: Voluntary?
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    private var photoStr: String?

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameText: UserTextField!
    @IBOutlet weak var alertNameLabel: UILabel!
    @IBOutlet weak var emailText: EmailTextField!
    @IBOutlet weak var alertEmailLabel: UILabel!
    @IBOutlet weak var phoneText: PhoneTextField!
    @IBOutlet weak var alertPhoneLabel: UILabel!
    
    @IBAction func confirmEditionButton(_ sender: UIBarButtonItem) {
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let name = self?.nameText.text ?? ""
                let phone = self?.phoneText.text ?? ""
                self?.saveVoluntaryData(withName: name, phone: phone)
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.becomeFirstNotValidFieldFirstResponder()
            }
        })
    }
    @IBAction func changePhotoButton(_ sender: UIButton) {
        pickImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let voluntary = voluntary {
            loadVoluntaryData(with: voluntary)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerFieldsToDinamicValidation()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deRegisterFieldsToDinamicValidation()
    }
    private func setupUI() {
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.clipsToBounds = true
        nameText.delegate = self
        emailText.isEnabled = false
        phoneText.delegate = self
        eiaTextFields = [nameText, phoneText]
        alertLabels = [alertNameLabel, alertPhoneLabel]
    }
    private func loadVoluntaryData(with voluntary: Voluntary) {
        nameText.text = voluntary.name
        emailText.text = voluntary.email
        phoneText.text = voluntary.phone
        if let photoStr = voluntary.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            self.photoStr = photoStr
            photoImageView.image = photoImage
        } else {
            self.photoStr = nil
            // load default user photo...
        }
    }
    private func saveVoluntaryData(withName name: String, phone: String) {
        let context: NSManagedObjectContext = containter.viewContext
        guard let voluntary = voluntary else {return}
        guard let authId = voluntary.authId else {return}
        voluntary.name = name
        voluntary.phone = phone
        voluntary.photo_str = photoStr
        try? context.save()
        fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(authId).setValue(voluntary.dictionaryValue)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = EiaColors.SunSet
        }
    }
    private func pickImage() {
        let pickImageAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        pickImageAlert.addAction(UIAlertAction(title: "Escolher foto", style: .default, handler: {[unowned self] (action) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.present(picker, animated: true, completion: nil)
        }))
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickImageAlert.addAction(UIAlertAction(title: "Tirar foto", style: .default, handler: {[unowned self] (action) in
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }))
        }
        pickImageAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(pickImageAlert, animated: true, completion: nil)
    }
}

extension EditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photoImageView.image = pickedImage
            if let imageData = pickedImage.pngData() {
                let imageStr = imageData.base64EncodedString()
                photoStr = imageStr
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
