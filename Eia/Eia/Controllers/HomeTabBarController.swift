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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        selectedIndex = 2
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({[weak self] (auth, user) in
            guard let user = user else {
                self?.goToLoginScreen()
                return
            }
            self?.retrieveVoluntary(withUser: user)
        })
        guard let currentUser = Auth.auth().currentUser else {return}
        retrieveVoluntary(withUser: currentUser)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    private func goToLoginScreen() {
        let mainStoryBorad = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = mainStoryBorad.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initialViewController
    }
    private func retrieveVoluntary(withUser user: User) {
        let context: NSManagedObjectContext = containter.viewContext
        guard let email = user.email else {
            goToLoginScreen()
            return
        }
        if let voluntary = Voluntary.find(matching: email, in: context) {
            self.voluntary = voluntary
        }
        
        let authId = user.uid
        fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).child(authId).observeSingleEvent(of: .value) {[weak self] (snapshot) in
            if let voluntaryDictionary = snapshot.value as? NSDictionary {
                if let retrievedVoluntary = Voluntary.createOrUpdate(matchDictionary: voluntaryDictionary, in: context) {
                    let status = retrievedVoluntary.status ?? ""
                    if status == VoluntaryStatus.pending.stringValue {
                        retrievedVoluntary.status = VoluntaryStatus.active.stringValue
                        try? context.save()
                        self?.fbDbRef.child(Voluntary.rootFirebaseDatabaseReference).child(authId).setValue(retrievedVoluntary.dictionaryValue)
                    } else {
                        try? context.save()
                    }
                    self?.voluntary = retrievedVoluntary
                    return
                }
            }
            let name = "Novo Voluntário"
            self?.voluntary = Voluntary.create(with: user, name: name, in: context)
            try? context.save()
        }
    }

}

extension HomeTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            if let profileController = navigationController.viewControllers.first as? ProfileViewController {
                profileController.voluntary = voluntary                
            }
        }
    }
}
