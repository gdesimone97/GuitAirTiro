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
    
    let game = GuitAirGameCenter.share
    
    let imagePickerController = UIImagePickerController()
    var flag = true
    let userDefaults = UserDefaults.standard
    let gameCenter = GuitAirGameCenter.share
    override func viewDidLoad() {
        super.viewDidLoad()
        pickButton.setTitle("", for: UIControl.State.normal  )
        
        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2;
        self.imageProfile.clipsToBounds = true;
        innerView.layer.cornerRadius = 14
        
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self
        
    }
    
     override func viewWillAppear(_ animated: Bool) {
        if flag {
            reloadStatOnline()
            flag = true
        }
    }
    
    private func reloadStatOnline() {
        let res = gameCenter.getMyProfile()
        if res.0 == 200 || res.0 == 201 {
            let profile = res.1
            let score = profile["total_score"]
            let wins = profile["wins"]
            let draws = profile["draws"]
            let losses = profile["losses"]
            let gamertagString = profile["gamertag"]
            let image = profile["image"]
            let array = [score,wins,draws,losses]
            var i = 0
            gamerTag.text = gamertagString
            if image != "empty" {
                imageProfile.image = convertStringToImage(string: image!)
            }
            for label in self.statLabel {
                label.text = String(array[i]!)
                i += 1
            }
            DispatchQueue.main.async {
                if image == "empty" {                PersistanceManager.UploadStat(score: Int(score!), wins: Int(wins!), draws: Int(draws!), losses: Int(losses!), image: nil, gamerTag: gamertagString)
                }
                else {
                    
                    PersistanceManager.UploadStat(score: Int(score!), wins: Int(wins!), draws: Int(draws!), losses: Int(losses!), image: nil , gamerTag: gamertagString)
                }
            }
        }
    }
    
    private func loadImageOffline() {
        if let resultImage = self.getImage(){
            self.imageProfile.image = resultImage
        }
    }
    
    private func reloadStatOffline() {
        let arrayStat = PersistanceManager.retriveStat()
        var i = 0
        for label in self.statLabel {
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
    
    private func convertImageToString(image: UIImage) -> String {
        let dataImage = image.pngData()
        return String(data: dataImage!, encoding: .unicode)!
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
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.imageProfile.image = image
        flag = false
        //print(self.convertImageToString(image: image))
        DispatchQueue.main.async {
            let res = self.game.updateImage(image: self.convertImageToString(image: image))
            if res.0 == 200 || res.0 == 201 {
                print("Salvato")
            }
            else {
                print(res.0)
                print(res.1)
                print("Non salvato")
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
