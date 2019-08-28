//
//  AccountViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 01/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import Network

class AccountViewController: UIViewController {
    let monitor = NWPathMonitor()
    let networkThread = DispatchQueue.init(label: "network_thread")
    var connectionFlag = false
    var connection: Bool!
    @IBOutlet var pickButton: UIButton!
    @IBOutlet var innerView: UIView!
    @IBOutlet var imageProfile: UIImageView!
    
    @IBOutlet var gamerTag: UILabel!
    @IBOutlet var statLabel: [UILabel]!
    @IBOutlet var logOutButton: UIButton!
    
    let game = GuitAirGameCenter.share
    
    let imagePickerController = UIImagePickerController()
    var flag = true
    let userDefaults = UserDefaults.standard
    let gameCenter = GuitAirGameCenter.share
    override func viewDidLoad() {
        super.viewDidLoad()
        monitor.pathUpdateHandler = deviceOnline(path:)
        monitor.start(queue: networkThread)
        pickButton.setTitle("", for: UIControl.State.normal  )
        
        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2;
        self.imageProfile.clipsToBounds = true;
        innerView.layer.cornerRadius = 14
        
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self
    }
    
    let thread = DispatchQueue.init(label: "photo")
    let threadCoreData = DispatchQueue.init(label: "core_thread")
    
     override func viewWillAppear(_ animated: Bool) {
        if flag {
            if userDefault.bool(forKey: UPLOAD) {
                let img = PersistanceManager.retriveImage()
                HadlerProfile.uploadImage(image: UIImage(data: img as! Data)!)
                userDefault.set(0, forKey: UPLOAD)
            }
            else {
                let profile = HadlerProfile.loadProfile()
                let array = [profile.score,profile.wins,profile.draws,profile.losses]
                var i = 0
                for label in statLabel{
                    label.text = String(array[i])
                    i += 1
                }
                gamerTag.text = profile.gamerTag
                imageProfile.image = profile.image
            }
        }
        else {
            flag = true
        }
    }
    
    private func deviceOnline(path: NWPath) {
        if path.status == .satisfied {
            connection = true
            DispatchQueue.main.async {
                self.logOutButton.isEnabled = true
                self.logOutButton.setTitleColor(.white, for: .normal)
            }
            if userDefault.bool(forKey: UPLOAD) {
                let myimage = UIImage(data: PersistanceManager.retriveImage() as! Data)
                HadlerProfile.uploadImage(image: myimage!)
                userDefault.set(0, forKey: UPLOAD)
            }
        }
        else {
            connection = false
            DispatchQueue.main.async {
                self.logOutButton.isEnabled = false
                self.logOutButton.setTitleColor(.gray, for: .disabled)
            }
        }
    }
    
    private func loadImage() {
        if let resultImage = self.getImage(){
            self.imageProfile.image = resultImage
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
    
    private func convertImageToString(image: UIImage) -> String {
        let data = (image.jpegData(compressionQuality: 0.0)?.base64EncodedString())!
        return data
    }
    
    private func convertStringToImage(string: String) -> UIImage {
        let data = Data(base64Encoded: string)
        return UIImage(data: data!)!
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        userDefaults.set(0,forKey: LOGIN)
        userDefaults.set(nil, forKey: JWT_STRING)
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
        
        let removeImage = UIAlertAction(title: "Remove Image", style: .destructive, handler: {action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let defaultImage = UIImage(named: "profile.png")
                DispatchQueue.main.async {
                    self.imageProfile.image = defaultImage
                }
                if self.connection {
                    HadlerProfile.uploadImage(image: defaultImage!)
                }
                else {
                    userDefault.set(1, forKey: UPLOAD)
                }
                self.threadCoreData.async {
                    PersistanceManager.uploadImage(image: defaultImage!)
                    print("Immagine aggiornata nel core data")
                }
            }
        })
        
        let cancellAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        allert.addAction(cameraAction)
        allert.addAction(albumAction)
        allert.addAction(removeImage)
        allert.addAction(cancellAction)
        
        self.present(allert,animated: true,completion: nil)
    }
    
    private func open() {
        self.present(imagePickerController,animated: true,completion: nil)
    }
    
}


extension AccountViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.imageProfile.image = image
        flag = false
        picker.dismiss(animated: true, completion: nil)
        thread.async {
            let res = HadlerProfile.uploadImage(image: image)
            if res == 200 || res == 201 {
                print("Salvato")
            }
            else {
                self.userDefaults.set(1, forKey: UPLOAD)
            }
        }
        threadCoreData.async {
            PersistanceManager.uploadImage(image: image)
            print("Immagine aggiornata nel core data")
        }
    }
}
