//
//  ViewController.swift
//  Firebase-practice
//
//  Created by TaiHsinLee on 2018/9/3.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setValue()
//        readData()
    }
    
    func setValue() {
        let uid = ref.child("users").childByAutoId().key
        self.ref.child("users").child(uid).setValue(["email": "spock@gmail.com", "name": "Spock", "friends": ["Nia": true, "Crystal": true]])
    }
    
    func readData() {
        
        ref.child("users").child("Nia").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let userName = value?["name"] as? String
            print(userName)
            let userEmail = value?["email"] as? String
            print(userEmail)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
//    func updateData() {
//        let key = ref.child("users").childByAutoId().key
//        let post = ["uid": userID,
//                    "author": username,
//                    "title": title,
//                    "body": body]
//        let childUpdates = ["/posts/\(key)": post,
//                            "/user-posts/\(userID)/\(key)/": post]
//        ref.updateChildValues(childUpdates)
//    }
//
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

