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
import FirebaseStorage

class EditProfileTableViewController: EiaFormTableViewController {
    public var voluntary: Voluntary?
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    private var photoStr: String?
    private var photoId: String?
    private var photoURL: String?
    private var photoData: Data?
    private var newPhotoId: String?

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
//        loadVoluntaryPhoto(with: voluntary)
        
        if let photoStr = voluntary.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            self.photoStr = photoStr
            photoImageView.image = photoImage
        } else {
            self.photoStr = nil
            let defaultPhoto = UIImage(named: "voluntary_default_icon")
            photoImageView.image = defaultPhoto
        }
    }
    private func loadVoluntaryPhoto(with voluntary: Voluntary) {
        let context = containter.viewContext
        if let photoData = voluntary.photo_data, let photoImage = UIImage(data: photoData) {
            photoImageView.image = photoImage
        } else {
            let defaultPhoto = UIImage(named: "voluntary_default_icon")
            photoImageView.image = defaultPhoto
            if let photoURL = voluntary.photo_url {
                downloadVoluntaryPhoto(withDownloadURL: photoURL, completion: {(photoData, error) in
                    if let photoData = photoData,  let photoImage = UIImage(data: photoData) {
                        DispatchQueue.main.async {[weak self] in
                            self?.photoImageView.image = photoImage
                            voluntary.photo_data = photoData
                            try? context.save()
                        }
                    }
                })
            }

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
    // Fazer o upload da photo para o firebase Storage e retornar a URL para download...
    private func uploadVoluntaryPhoto(withPhotoData photoData: Data, photoId: String, voluntaryId: String, completion: @escaping (URL?, Error?) -> Void) {
        let fileName = photoId + ".png"
        let fileMetaData = StorageMetadata()
        fileMetaData.contentType = "image/png"
        let fbStRef = Storage.storage().reference().child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(fileName)
        let _ = fbStRef.putData(photoData, metadata: fileMetaData, completion: {(metaData, error) in
            if let error = error {
                completion(nil, error)
            } else {
                fbStRef.downloadURL(completion: {(url, error) in
                    completion(url, error)
                })
            }
        })
    }
    private func downloadVoluntaryPhoto(withDownloadURL downloadURL: String, completion: @escaping (Data?, Error?) -> Void) {
        let fbStRef = Storage.storage().reference(forURL: downloadURL)
        fbStRef.getData(maxSize: 1 * 1024 * 1024, completion: {(photoData, error) in
            completion(photoData, error)
        })
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
            if let imageData = pickedImage.pngData() {
                photoData = imageData
                photoStr = imageData.base64EncodedString()
                newPhotoId = UUID().uuidString
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
