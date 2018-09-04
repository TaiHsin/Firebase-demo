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
    @IBOutlet weak var friendsEmailText: UITextField!
    @IBOutlet weak var friendsArticles: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var tagArticles: UIButton!
    @IBOutlet weak var allArticles: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        guard let userId = UserManager.shared.getUserId() else { return }
        ref.child("users").child(userId).child("contact").observe(.childAdded) { (snapshot) in
            let friendKey = snapshot.key
            
            guard let value = snapshot.value as? String else { return }
            if value == "待邀請"{
                return
            } else if value == "待接受" {
                self.ref.child("users").child(snapshot.key).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value)
                    guard let name = snapshot.value as? String else { return }
                    self.showAlertWith(userId: userId, friendKey: friendKey, name: name)
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cornerRadius()
        guard let email = UserManager.shared.getUserEmail() else { return }
        if email == "" || email == nil {
            userName.isUserInteractionEnabled = true
            userEmail.isUserInteractionEnabled = true
        } else {
            createButton.isHidden = true
            userName.isUserInteractionEnabled = false
            userEmail.isUserInteractionEnabled = false
        }
    }
    
    func cornerRadius() {
        createButton.layer.cornerRadius = 5
        articleContent.layer.cornerRadius = 5
        postArticleButton.layer.cornerRadius = 5
        addFriendButton.layer.cornerRadius = 5
        friendsArticles.layer.cornerRadius = 5
        tagArticles.layer.cornerRadius = 5
        allArticles.layer.cornerRadius = 5
        resetButton.layer.cornerRadius = 5
    }
   
    @IBAction func createUser(_ sender: Any) {
        
        createUser()
        
        userName.text = ""
        userEmail.text = ""
    }
    
    @IBAction func resetUser(_ sendor: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "userId")
        userDefaults.removeObject(forKey: "userName")
        userDefaults.removeObject(forKey: "userEmail")
    }
    
    @IBAction func getAllArticles(_ sender: Any) {
        let tag = segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)
        guard let tagName = tag else { return }
        
        getTagData(byTag: tagName)
    }

    @IBAction func postArticle(_ sender: Any) {
        guard let title = articleTitle.text else { return }
        guard let content = articleContent.text else { return }
        
        let tag = segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)
        guard let tagName = tag else { return }
        
        postArticle(title: title, content: content, tag: tagName, time: "20180904")
 
        articleTitle.text = ""
        articleContent.text = ""
    }
    
    // MARK: - Search friend's mail and invide as friend
    
    @IBAction func addFriends(_ sender: Any) {
        guard let email = friendsEmailText.text else { return }
        guard let userId = UserManager.shared.getUserId() else { return }
        
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value as Any)
            guard value != nil else {
                print("User doesn't exist!")
                return
            }
            
            guard let valueKey = value?.allKeys[0] as? String else {
                return
            }
            self.ref.updateChildValues(["/users/\(valueKey)/contact/\(userId)": "待接受"])
            self.ref.updateChildValues(["/users/\(userId)/contact/\(valueKey)": "待邀請"])
            
            self.friendsEmailText.text = ""
        }
    }
    
    // MARK: - Get friends all articles
    
    @IBAction func showFriendsArticles(_ sender: Any) {
        guard let email = friendsEmailText.text else { return }
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            guard let valueKey = value?.allKeys[0] as? String else {
                return
            }
            self.ref.child("posts").queryOrdered(byChild: "author_id").queryEqual(toValue: valueKey).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                print(value as Any)
            })
        }
        friendsEmailText.text = ""
    }
    
    // MARK: - Get friends certain tag's articles
    
    @IBAction func getFriendsTagArticles(_ sender: Any) {
        let tag = segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)
        guard let tagName = tag else { return }
        
        guard let email = friendsEmailText.text else { return }
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            guard let valueKey = value?.allKeys[0] as? String else {
                return
            }
            print(value)
            
            self.ref.child("posts").queryOrdered(byChild: "author_id").queryEqual(toValue: valueKey).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                guard let valueArray = value?.allValues else { return }
                print(value as Any)
                
                for item in valueArray {
                    guard let dictionaryData = item as? [String: Any] else { return }
                    let tag = dictionaryData["article_tag"] as? String
                    if tag == tagName {
                        print(tag)
                        print(item)
                    }
                }
            })
        }
        friendsEmailText.text = ""
    }
    
    // MARK: - Create user data
    
    func createUser() {
        let uid = ref.child("users").childByAutoId().key
        self.ref.child("users").child(uid).setValue(["email": userEmail.text , "name": userName.text])

        UserDefaults.standard.set(uid, forKey: "userId")
        UserDefaults.standard.set(userName.text, forKey: "userName")
        UserDefaults.standard.set(userEmail.text, forKey: "userEmail")
    }
    
    // MARK: - Search tag articles
    
    func getTagData(byTag tag: String) {
        ref.child("posts").queryOrdered(byChild: "article_tag").queryEqual(toValue: tag).observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            print(value)
        }
    }
    
    // MARK: - Read data at certain child
    
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
    
    // MARK: - Use update to post new article
    
    func postArticle(title: String, content: String, tag: String, time: String) {
        let key = ref.child("posts").childByAutoId().key
        guard let userId = UserManager.shared.getUserId() else { return }
        guard let userName = UserManager.shared.getUserName() else { return }
    
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let time = dateFormatter.string(from: date)
        print(time)
        
        let post = ["article_id": key,
                    "article_title": title,
                    "article_content": content,
                    "article_tag": tag,
                    "author_id": userId,
                    "author_name": userName,
                    "created_time": time ] as [String : Any]
        let postUpdates = ["/posts/\(key)": post]
        
        ref.updateChildValues(postUpdates)
    }
}

// MARK: - Show alert with new friends request

extension ViewController {
    
    func showAlertWith(userId: String, friendKey: String, name: String) {
        let alerController = UIAlertController(title: "New friend", message: "\(name) send you a friend request!" , preferredStyle: .alert)
        alerController.addAction(UIAlertAction(title: "Reject", style: .default, handler: { (_) in
            self.ref.child("/users/\(userId)/contact/\(friendKey)").setValue(nil)
            self.ref.child("/users/\(friendKey)/contact/\(userId)").setValue(nil)
        }))
        alerController.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (_) in
            
            self.ref.updateChildValues(["/users/\(userId)/contact/\(friendKey)": true])
            self.ref.updateChildValues(["/users/\(friendKey)/contact/\(userId)": true])
        }))
        self.present(alerController, animated: true, completion: nil)
    }
}
