//
//  HomeTabBarController.swift
//  Eia
//
//  Created by Cleofas Pereira on 30/12/18.
//  Copyright © 2018 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class HomeTabBarController: UITabBarController {
    private var containter: NSPersistentContainer = AppDelegate.persistentContainer!
    private var voluntary: Voluntary?
    private var handle: AuthStateDidChangeListenerHandle?
    private var fbDbRef = Database.database().reference()
    private var updateVoluntaryDelegate: UpdateVoluntaryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        selectedIndex = 2
        guard let currentUser = Auth.auth().currentUser else {return}
        let currentUserId = currentUser.uid
        retrieveVoluntary(withUser: currentUser)
        handle = Auth.auth().addStateDidChangeListener({[weak self] (auth, user) in
            guard let user = user else {
                self?.goToLoginScreen()
                return
            }
            self?.retrieveVoluntary(withUser: user)
        })
        startChangeVoluntaryListener(withIdentifier: currentUserId)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        fbDbRef.removeAllObservers()
    }
    private func goToLoginScreen() {
        let mainStoryBorad = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = mainStoryBorad.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initialViewController
    }
    private func updateVoluntary(withUser user: User) {
        let context: NSManagedObjectContext = containter.viewContext
        DispatchQueue.main.async {[weak self] in
            if let volunteer = Voluntary.find(matching: user.uid, in: context) {
                self?.voluntary = volunteer
            }
        }
    }
    private func updateVolutary(withDictionary dictionary: NSDictionary) {
        let context: NSManagedObjectContext = containter.viewContext
        DispatchQueue.main.async {[weak self] in
            if let retrievedVoluntary = Voluntary.createOrUpdate(matchDictionary: dictionary, in: context) {
                let status = retrievedVoluntary.status ?? ""
                if status == VoluntaryStatus.pending.stringValue {
                    let voluntaryId = retrievedVoluntary.authId ?? ""
                    retrievedVoluntary.status = VoluntaryStatus.active.stringValue
                    try? context.save()
                    self?.fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).child(voluntaryId).setValue(retrievedVoluntary.dictionaryValue)
                } else {
                    try? context.save()
                }
                self?.voluntary = retrievedVoluntary
                if let updateVoluntaryDelegate = self?.updateVoluntaryDelegate {
                    updateVoluntaryDelegate.voluntaryHasBeenUpdated(withVoluntary: retrievedVoluntary)
                }
            }
        }
    }
    private func startChangeVoluntaryListener(withIdentifier identifier: String) {
        fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).child(identifier).observe(.childChanged, with: {[weak self] (snapshot) in
            if let voluntaryDictionary = snapshot.value as? NSDictionary {
                self?.updateVolutary(withDictionary: voluntaryDictionary)
            }
        })
    }
    private func retrieveVoluntary(withUser user: User) {
        let context: NSManagedObjectContext = containter.viewContext
        let authId = user.uid
        fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).child(authId).observeSingleEvent(of: .value) {[weak self] (snapshot) in
            if let voluntaryDictionary = snapshot.value as? NSDictionary {
                self?.updateVolutary(withDictionary: voluntaryDictionary)
            } else {
                let name = "Novo Voluntário"
                self?.voluntary = Voluntary.create(with: user, name: name, in: context)
                try? context.save()
            }
        }
    }
}

extension HomeTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let currentUser = Auth.auth().currentUser else {return}
        updateVoluntary(withUser: currentUser)
        
        if let navigationController = viewController as? UINavigationController {
            let destination = navigationController.viewControllers.first
            if let teamsController = destination as? TeamsTableViewController {
                teamsController.voluntary = voluntary
            }
            if let scalesController = destination as? ScalesTableViewController {
                scalesController.voluntary = voluntary
            }
            if let noticesController = destination as? NoticesTableViewController {
                noticesController.voluntary = voluntary
            }
            if let groupsController = destination as? GroupsTableViewController {
                groupsController.voluntary = voluntary
            }
            if let profileController = destination as? ProfileViewController {
                profileController.voluntary = voluntary
            }
        }
    }
}

protocol UpdateVoluntaryDelegate {
    func voluntaryHasBeenUpdated(withVoluntary voluntary: Voluntary)
}
