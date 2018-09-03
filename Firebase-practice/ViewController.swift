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
    
   
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var articleTitle: UITextField!
    @IBOutlet weak var articleContent: UITextView!
    @IBOutlet weak var postArticleButton: UIButton!
    @IBOutlet weak var friendsEmail: UITextField!
    @IBOutlet weak var friendsArticles: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBAction func switchTag(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            getTagData(byTag: "表特")
        case 1:
            getTagData(byTag: "八卦")
        case 2:
            getTagData(byTag: "就可")
        case 3:
            getTagData(byTag: "生活")
        default: break
        }
    }
    
    @IBAction func postArticle(_ sender: Any) {
    }
    
    @IBAction func addFriends(_ sender: Any) {
    }
    
    @IBAction func showFriendsArticles(_ sender: Any) {
    }
    
    @IBAction func createUser(_ sender: Any) {
        createUser()
        userName.text = ""
        userEmail.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        searchUser(byEmail: "peterlee0466@gmail.com")
        
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createButton.layer.cornerRadius = 5
        articleContent.layer.cornerRadius = 5
        postArticleButton.layer.cornerRadius = 5
        addFriendButton.layer.cornerRadius = 5
        friendsArticles.layer.cornerRadius = 5
    }
    
    // MARK: - Create user data
    
    func createUser() {
        let uid = ref.child("users").childByAutoId().key
        print(uid)
        UserDefaults.standard.set(uid, forKey: "userId")
        self.ref.child("users").child(uid).setValue(["email": userEmail.text , "name": userName.text])
    }
    
    // MARK: - Search tag articles
    
    func getTagData(byTag tag: String) {
        ref.child("posts").queryOrdered(byChild: "表特").queryEqual(toValue: true).observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            print(value)
        }
    }
    
    func readData() {
        ref.child("users").child("Nia").observeSingleEvent(of: .value) { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let userName = value?["name"] as? String
            print(userName!)
            let userEmail = value?["email"] as? String
            print(userEmail!)
        }
    }
    
    func searchUser(byEmail email: String) {
        
        ref.child("posts").queryOrdered(byChild: "表特").queryEqual(toValue: true).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
//            guard let valueKey = value?.allKeys[0] as? String else { return }
//            let userValue = value?[valueKey] as? NSDictionary
//            let dataValue = userValue!["name"]! as? String
            print(value)
        }
    }
    
    func updateData() {
        let key = ref.child("posts").childByAutoId().key
        let user = ["id": "4521h93h8f92h", "name": "Taihsin"]
        let post = ["article_content": "1234567890",
                    "article_id": "4567",
                    "article_tag": ["表特": true],
                    "article_title": "midnight desert time", "author": user, "created_time": "2018_9_19" ] as [String : Any]
        let childUpdates = ["/posts/\(key)": post]
        ref.updateChildValues(childUpdates)
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

