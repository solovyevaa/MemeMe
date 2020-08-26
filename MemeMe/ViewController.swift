//
//  ViewController.swift
//  MemeMe
//
//  Created by Anna Solovyeva on 19/06/2020.
//  Copyright © 2020 Anna Solovyeva. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navigation: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    
    func setupTextFieldStyle(textField: UITextField, defaultText: String) {
        textField.text = defaultText
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.textColor = UIColor.white
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFieldStyle(textField: self.textFieldTop, defaultText: "TOP")
        setupTextFieldStyle(textField: self.textFieldBottom, defaultText: "BOTTOM")
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotifications()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    func imagePicker(pickerType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = pickerType
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func pickTheImageFromAlbum(_ sender: Any) {
        imagePicker(pickerType: .photoLibrary)
        shareButton.isEnabled = true
    }
    
    
    @IBAction func pickTheImageFromCamera(_ sender: Any) {
        imagePicker(pickerType: .camera)
    }
    
    
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            self.imagePickerView.contentMode = .scaleAspectFit
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textFieldTop.isEditing {
            textFieldTop.text = ""
        }
        
        if textFieldBottom.isEditing {
            textFieldBottom.text = ""
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldTop.resignFirstResponder()
        textFieldBottom.resignFirstResponder()
        return true;
    }
    
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
    ]
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if self.textFieldBottom.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func isToolbarHidden(hidden: Bool) {
        if hidden {
            toolbar.isHidden = true
            navigation.isHidden = true
        }
        else {
            toolbar.isHidden = false
            navigation.isHidden = false
        }
    }
    
    
    func generateMemedImage() -> UIImage {
        isToolbarHidden(hidden: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        isToolbarHidden(hidden: false)
        
        return memedImage
    }
    
    
    func save(_ memedImage: UIImage) {
        let meme = Meme(topText: textFieldTop.text!, bottomText: textFieldBottom.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    
    @IBAction func shareMeme(_ sender: Any) {
        let memeImage = generateMemedImage()
        let uiController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        present(uiController, animated: true, completion: nil)
        
        uiController.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
            if completed {
                self.save(memeImage)
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
