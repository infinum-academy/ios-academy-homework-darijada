//
//  ViewController.swift
//  TVShows
//
//  Created by Infinum on 4/13/1398 AP.
//  Copyright © 1398 Infinum Academy. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import CodableAlamofire

final class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var createAccountButton: UIButton!
    @IBOutlet private weak var checkmarkButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    private var _infoLabel: String = "Unknown"
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.layer.cornerRadius = 6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func loginFailureAlert(){
        let alert = UIAlertController(title: "Login failure alert", message: "Incorrect Email or Password!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction private func logInButtonActionHandler() {
        guard let userEmail = emailTextField.text else { return }
        guard let userPassword = passwordTextField.text else { return }
        loginUser(email: userEmail, password: userPassword)
   }

    @IBAction private func createAccountButtonActionHandler() {
        guard let userEmail = emailTextField.text else { return }
        guard let userPassword = passwordTextField.text else { return }
        createUserAccount(email: userEmail, password: userPassword)    }
    
}

    // MARK: - Register + automatic JSON parsing

private extension LoginViewController {
    
    func createUserAccount(email: String, password: String) {
        SVProgressHUD.show()
        
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        Alamofire
            .request(
                "https://api.infinum.academy/api/users",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { (response: DataResponse<User>) in
                switch response.result {
                case .success(let user):
                   print("Success: \(user)")
                   SVProgressHUD.showSuccess(withStatus: "User registered!")
                    
                case .failure(let error):
                    print("API failure: \(error)")
                    SVProgressHUD.showError(withStatus: "Email or Password field is required!")
                }
        }
    }
}

    // MARK: - Login + automatic JSON parsing

private extension LoginViewController {
    
    func loginUser(email: String, password: String) {
        SVProgressHUD.show()
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        Alamofire
            .request(
                "https://api.infinum.academy/api/users/sessions",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default)
            .validate()
            .responseDecodableObject(keyPath: "data", completionHandler: { [weak self] (response: DataResponse<LoginData>) in
                switch response.result {
                case .success(let loginData):
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let viewController = storyboard.instantiateViewController( withIdentifier: "HomeViewController") as! HomeViewController
                    viewController.token = loginData.token
                    self?.navigationController?.pushViewController(viewController, animated: true)
                    SVProgressHUD.showSuccess(withStatus: "Successful login!")
                case .failure(let error):
                    self?._infoLabel = "API failure: \(error)"
                    SVProgressHUD.dismiss()
                    self?.loginFailureAlert()
                }
            })
    }
}
