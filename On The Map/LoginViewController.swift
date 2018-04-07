//
//  LoginViewController.swift
//  On The Map
//
//  Created by Hao Wu on 9/3/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: Any) {
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            /*
             Steps for Authentication...
             https://www.themoviedb.org/documentation/api/sessions
             
             Step 1: Create a request token
             Step 2: Ask the user for permission via the API ("login")
             Step 3: Create a session ID
             
             Extra Steps...
             Step 4: Get the user id ;)
             Step 5: Go to the next view!
             */
            //getRequestToken()
            login();
        }
    }
    
    @IBAction func userDidTapView(_ sender: Any) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    // MARK: TheMovieDB
    
    private func login() {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(usernameTextField!.text!)\", \"password\": \"\(passwordTextField!.text!)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            //print(String(data: newData!, encoding: .utf8)!)
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
                if let session = parsedResult["session"] {
                    self.appDelegate.sessionID = (session as! [String:AnyObject])["id"] as? String
                    self.appDelegate.sessionExpiration = (session as! [String:AnyObject])["expiration"] as? String
                    
                }
                if let account = parsedResult["account"] {
                    self.appDelegate.accountRegistered = (account as! [String:AnyObject])["registered"] as? Bool
                    self.appDelegate.accountKey = (account as! [String:AnyObject])["key"] as? String
                    self.appDelegate.studentLocation.UniqueKey = self.appDelegate.accountKey!
                    
                    
                }
                if let registered = self.appDelegate.accountRegistered {
                    if registered {
                        self.completeLogin();
                    }
                }
            } catch {
                return
            }
            
            DispatchQueue.main.async {
                self.setUIEnabled(true)
            }
            
            
        }
        task.resume()
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    

}

// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }
    
    func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        //textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    

}
