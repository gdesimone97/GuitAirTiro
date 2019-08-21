//
//  AccountViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 01/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet var pickButton: UIButton!
    @IBOutlet var innerView: UIView!
    @IBOutlet var imageProfile: UIImageView!
    
    @IBOutlet var gamerTag: UILabel!
    @IBOutlet var statLabel: [UILabel]!
    
    
    let imagePickerController = UIImagePickerController()
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickButton.setTitle("", for: UIControl.State.normal  )
        
//        if let image = userDefaults.getImage(forKey: IMAGE_DEFAULT) {
//            imageProfile.image = image
//        }
        
        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2;
        self.imageProfile.clipsToBounds = true;
        innerView.layer.cornerRadius = 14
        
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self
        
        reloadStat()
       
    }
    
    private func reloadStat() {
        if let resultImage = getImage(){
            imageProfile.image = resultImage
        }
        
        let arrayStat = PersistanceManager.retriveStat()
        var i = 0
        for label in statLabel {
            label.text = String(arrayStat[i])
            i += 1
        }
    }
    
    private func getImage() -> UIImage? {
        let imageTemp = PersistanceManager.retriveImage()
        guard imageTemp != nil else { return nil }
        let dataImage = imageTemp! as Data
        let imageNotRotate = UIImage(data: dataImage)
        let imageWillRotate = imageNotRotate?.cgImage
        return UIImage(cgImage: imageWillRotate!, scale: CGFloat(1.0), orientation: .right)
    }
    
    private func convertImageToData(image: UIImage) -> NSData? {
        let dataImage = image.pngData()
        return NSData(data: dataImage!)
    }

    @IBAction func logOutButton(_ sender: Any) {
        userDefaults.set(0,forKey: LOGIN)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        showAllert()
    }
    
    private func showAllert() {
        let allert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.open()
            }
        })
        let albumAction = UIAlertAction(title: "Album", style: .default, handler: {action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePickerController.sourceType = .photoLibrary
                self.open()
            }
        })
        
        let cancellAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        allert.addAction(cameraAction)
        allert.addAction(albumAction)
        allert.addAction(cancellAction)
        
        self.present(allert,animated: true,completion: nil)
    }
    
    private func open() {
        self.present(imagePickerController,animated: true,completion: nil)
    }
    
}


extension AccountViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image =  info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.imageProfile.image = image
        //userDefault.setImage(image: image, forKey: IMAGE_DEFAULT)
        let imageToSave = convertImageToData(image: image)
        PersistanceManager.UploadStat(wins: nil, loose: nil, draws: nil, score: nil, image: imageToSave as Data?, gamerTag: nil)
        dismiss(animated: true, completion: nil)
    }
    
}

extension UserDefaults {
    func setImage(image: UIImage,forKey: String) {
        let dataImage = image.pngData()
        if dataImage == nil {
            print("Errore conversione")
            return
        }
        UserDefaults.standard.set(dataImage, forKey: forKey)
    }
    
    func getImage(forKey: String) -> UIImage? {
        let dataImage = UserDefaults.standard.object(forKey: forKey) as? Data
        if dataImage == nil {
            return nil
        }
        else {
            let imageNotRotate = UIImage(data: dataImage!)
            let imageWillRotate = imageNotRotate?.cgImage
            return UIImage(cgImage: imageWillRotate!, scale: CGFloat(1.0), orientation: .right)
        }
    }
}
