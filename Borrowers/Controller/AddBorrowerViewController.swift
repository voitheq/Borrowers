//
//  AddBorrowerViewController.swift
//  Borrowers
//
//  Created by Wojciech Karaś on 28/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit

protocol AddBorrowerViewControllerDelegate: class {
    func addBorrowerViewControllerDidCancel(_ controller: AddBorrowerViewController)
    func addBorrowerViewControllerDidFinishAdding(_ controller: AddBorrowerViewController)
}

class AddBorrowerViewController: UIViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var borrowerPhoto: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    weak var delegate: AddBorrowerViewControllerDelegate?
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(borrowerPhotoTapped(_:)))
        borrowerPhoto.isUserInteractionEnabled = true
        borrowerPhoto.addGestureRecognizer(tapGestureRecognizer)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        nameTextField.delegate = self
        nameTextField.becomeFirstResponder()
        
        emailTextField.delegate = self
    }
    
    @objc func borrowerPhotoTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else {
            return
        }
        if gestureRecognizer.state == .ended {
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        delegate?.addBorrowerViewControllerDidCancel(self)
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        let borrower = Borrower(entity: Borrower.entity(), insertInto: context)
        borrower.name = nameTextField.text!
        borrower.email = emailTextField.text
        borrower.photo = borrowerPhoto.image?.pngData() as NSData?
        appDelegate.saveContext()
        delegate?.addBorrowerViewControllerDidFinishAdding(self)
    }
}

extension AddBorrowerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === nameTextField {
            if let oldName = textField.text {
                if let stringRange = Range(range, in: oldName){
                    doneButton.isEnabled = !oldName.replacingCharacters(in: stringRange, with: string).isEmpty
                }
            }
        }
        return true
    }
}

extension AddBorrowerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            borrowerPhoto.image = editedImage
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
