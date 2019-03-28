//
//  EditGroupTableViewController.swift
//  Eia
//
//  Created by Cleofas Pereira on 24/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
import Photos
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class EditGroupTableViewController: EiaFormTableViewController {
    // MARK: - Public vars
    public var group: Group?
    
    // MARK: - Private vars
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private let fbDBRef = Database.database().reference()
    private var photoStr: String?
    private var volunteersDataSource: EditGroupVolunteersDataSource!
    private var teamsDataSource: EditGroupTeamsDataSource!
    
    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: GroupNameTextField!
    @IBOutlet weak var descriptionTextField: GroupDescriptionTextField!
    @IBOutlet weak var leaderNameTextField: UserTextField!
    @IBOutlet weak var alertNameLabel: UILabel!
    @IBOutlet weak var alertDescriptionLabel: UILabel!
    @IBOutlet weak var alertLeaderNameLabel: UILabel!
    @IBOutlet weak var teamTableView: UITableView!
    @IBOutlet weak var volunteerTableView: UITableView!
    
    @IBAction func confirmButton(_ sender: UIBarButtonItem) {
        performFormValidation(validationDidFinishWithSuccess: {[weak self] (formValid) in
            if formValid {
                let name = self?.nameTextField.text ?? ""
                let description = self?.descriptionTextField.text ?? ""
                let volunteerItems = self?.volunteersDataSource.selectedVolunteerItems ?? [Voluntary_Item]()
                let removedItems = self?.volunteersDataSource.removedVolunteerItems ?? [Voluntary_Item]()
                self?.saveGroupDataWithExit(withName: name, description: description, volunteerItems: volunteerItems, removedVolunteerItems: removedItems)
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
        updateUI()
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
        let context = containter.viewContext
        guard let group = group else {return}
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.clipsToBounds = true
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        leaderNameTextField.delegate = self
        leaderNameTextField.isEnabled = false
        eiaTextFields = [nameTextField, descriptionTextField]
        alertLabels = [alertNameLabel, alertDescriptionLabel]
        teamTableView.tableFooterView = UIView()
        volunteerTableView.tableFooterView = UIView()
        volunteersDataSource = EditGroupVolunteersDataSource(withGroup: group, context: context)
        volunteerTableView.dataSource = volunteersDataSource
        volunteerTableView.delegate = volunteersDataSource
        teamsDataSource = EditGroupTeamsDataSource(withGroup: group, context: context)
        teamTableView.dataSource = teamsDataSource
    }
    
    // exibir a tabela de equipes apenas para leitura...
    private func updateUI() {
        guard let group = group else {return}
        nameTextField.text = group.name
        descriptionTextField.text = group.group_description
        leaderNameTextField.text = group.leader_name
        if let photoStr = group.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            photoImageView.image = photoImage
            self.photoStr = photoStr
        } else {
            self.photoStr = nil
            let defaultPhoto = UIImage(named: "group_default_icon")
            photoImageView.image = defaultPhoto
        }
        volunteersDataSource.update {[weak self] in
            self?.volunteerTableView.reloadData()
            self?.volunteerTableView.setEditing(true, animated: true)
        }
        teamTableView.reloadData()
    }

    private func saveGroupDataWithExit(withName name: String, description: String, volunteerItems: [Voluntary_Item], removedVolunteerItems: [Voluntary_Item]) {
        let context: NSManagedObjectContext = containter.viewContext
        guard let group = group else {return}
        group.name = name
        group.group_description = description
        group.volunteers = NSSet(array: volunteerItems)
        group.photo_str = photoStr
        try? context.save()
        let groupId = group.identifier ?? ""
        fbDBRef.child(Group.rootFirebaseDatabaseReference).child(groupId).setValue(group.dictionaryValue)
        
        let leaderId = group.leader_id ?? ""
        if let leader = Voluntary.find(matching: leaderId, in: context) {
            if let groupItem = leader.findGroupItem(withGroupId: groupId, in: context) {
                groupItem.name = name
                try? context.save()
                fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(leaderId).child(Group_Item.rootFirebaseDatabaseReference).child(groupId).setValue(groupItem.dictionaryValue)
            }
        }
        
        for voluntaryItem in volunteerItems {
            let voluntaryId = voluntaryItem.identifier ?? ""
            if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
                if let groupItem = voluntary.findGroupItem(withGroupId: groupId, in: context) {
                    groupItem.name = name
                    try? context.save()
                    fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Group_Item.rootFirebaseDatabaseReference).child(groupId).setValue(groupItem.dictionaryValue)
                }
            }
        }
        
        for voluntaryItem in removedVolunteerItems {
            let voluntaryId = voluntaryItem.identifier ?? ""
            if let voluntary = Voluntary.find(matching: voluntaryId, in: context) {
                if let groupItem = voluntary.findGroupItem(withGroupId: groupId, in: context) {
                    voluntary.removeFromGroups(groupItem)
                    try? context.save()
                    fbDBRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).child(Group_Item.rootFirebaseDatabaseReference).child(groupId).removeValue()
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
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

extension EditGroupTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
