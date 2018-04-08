//
//  LoginViewController.swift
//  On The Map
//
//  Created by Hao Wu on 9/3/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    // MARK: IBActions
    
    @IBAction func loginPressed(_ sender: Any) {
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            login();
        }
    }
    
    @IBAction func userDidTapView(_ sender: Any) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: private functions
    
    //Log in and get the username for use in map
    private func login() {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(usernameTextField!.text!)\", \"password\": \"\(passwordTextField!.text!)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                performUIUpdatesOnMain {
                    self.networkFailed()
                }
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
                if let status = parsedResult["status"] {
                    let statusCode = status as! Int
                    //Log in failed
                    if statusCode == 403 {
                        performUIUpdatesOnMain {
                            self.loginError()
                        }
                        
                    }
                }
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
                        //Log in success
                        performUIUpdatesOnMain {
                            self.completeLogin()
                        }
                    }
                }

            } catch {
                return
            }
            self.getUserName()
        }
        task.resume()
    }
    

    
    private func getUserName() {
        let userId = appDelegate.studentLocation.UniqueKey
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userId)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */

            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
                if let user = parsedResult["user"] {
                    if let lastName = user["last_name"] {
                        self.appDelegate.studentLocation.LastName = lastName as! String
                    }
                    if let firstName = user["first_name"] {
                        self.appDelegate.studentLocation.FirstName = firstName as! String
                    }
                }
            } catch {
                return
            }
            performUIUpdatesOnMain {
                self.setUIEnabled(true)
            }
        }
        task.resume()
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
    
    private func completeLogin() {
        debugTextLabel.text = ""
        setUIEnabled(true)
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
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
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
    
    func loginError() {
        let message = "Invalid Email or Password."
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Cancel Log In"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Web API timeout
    func networkFailed() {
        let message = "There was an error retrieving log in info."
        let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Network Error"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
