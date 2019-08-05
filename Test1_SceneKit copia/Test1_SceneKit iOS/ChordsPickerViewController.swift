//
//  ChordsPickerViewController.swift
//  LetsPlayStoryboards
//
//  Created by Christian Marino on 15/07/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import UIKit


enum GuitarType {
    case elettric
    case classic
}

class ChordsPickerViewController: UIViewController,
UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var guitarLabel: UILabel!
    
    //confirm picked
    @IBOutlet weak var confirmNotification: UIImageView!
    
    
    //Datasource per i picker
    
    
    let engChords = ["A", "Am", "B", "Bm", "C","Cm","D","Dm","E","Em","F","Fm", "G", "Gm"];
    let italianChords = ["La","Lam","Si","Sim","Do","Dom","Re","Rem","Mi","Mim","Fa","Fam","Sol","Solm"]
    
    var chords = Array<String>()
    
    var language: String {
        get {
            return userDefault.string(forKey: USER_LANGUAGE)!
        }
    }
    @IBOutlet var chordPickers: [UIPickerView]!
    
    override func viewDidAppear(_ animated: Bool) {
        
        chords = language == "IT" ? italianChords : engChords
        for pick in chordPickers{
            pick.reloadComponent(0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chords = language == "IT" ? italianChords : engChords
        
        //Applico lo stile ad ogni bottone
        for b in buttons{
            b.layer.frame = CGRect(x: 30.51, y: 583.67, width: 153.02, height: 47);
            
            b.layer.backgroundColor = UIColor(red: 0.28, green: 0.32, blue: 0.37, alpha: 1).cgColor;
            
            b.layer.cornerRadius = 8;
        }
        
        
        for p in chordPickers{
            
            p.dataSource = self;
            p.delegate = self;
            
            p.layer.frame = CGRect(x: 183.83, y: 217.17, width: 78, height: 265.67)
            p.layer.backgroundColor = UIColor(red: 0.2, green: 0.25, blue: 0.29, alpha: 1).cgColor;
            p.layer.borderWidth = 0.3333333333333333
            p.layer.borderColor = UIColor(red: 0.75, green: 0.8, blue: 0.85, alpha: 1).cgColor
            //p.selectRow con usersetting
            //p.selectRow(2, inComponent: 0, animated: true);
            
        }
        
        if let testUserData = userDefault
            .array(forKey: USER_DEFAULT_KEY_ROW) {
            var valuesRead = testUserData as! [Int]
            var i : Int = 0;
            
            for pick in chordPickers {
                pick.selectRow(valuesRead[i%chords.count], inComponent: 0, animated: true);
                i+=1;
            }
        }
        
        // Do any additional setup after loading the view.
        //Carico gli accordi lastUsed salvati negli userdefault
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
       
        // confirm notification hidden
        confirmNotification.isHidden = true
        
        var color: UIColor!
        
        color = UIColor.orange;
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): color
            //        NSFontAttributeName.rawValue: UIFont.systemFontOfSize(15)
        ]
        
        return NSAttributedString(string: chords[row%chords.count], attributes: attributes);
    }
    
    
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //    pickerView.view(forRow: row, forComponent: component)?.backgroundColor = UIColor.green;
        
        pickerView.reloadAllComponents()
        
    }
    /*
     func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
     let titleData = chords[row%chords.count];
     let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor.orange])
     
     return myTitle;
     
     }
     
     */
    
    @IBOutlet var buttons: [UIButton]!;
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return loopMargin*chords.count;
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return chords[row%chords.count];
    }
    
    
    let loopMargin = 50;
    
    @IBAction func confirmButton(_ sender: Any) {
        
        var valuesToStore = Array <Int>(repeating: 0, count: 4)
        var str = Array<String>(repeating: "", count: 4)
        var j = 0
        for pick in chordPickers {
            let row = pick.selectedRow(inComponent: 0)
            str[j] = chords[row % chords.count]
            valuesToStore[j] = row
            j += 1
        }
        
        userDefault.set(valuesToStore, forKey: USER_DEFAULT_KEY_ROW)
        userDefault.set(str, forKey: USER_DEFAULT_KEY_STRING)
        
        print(valuesToStore)
        print(chords.count);
        var choice = "< ";
        for i in 0..<4{
            let post = i == 3 ? " >" : ", ";
            choice += chords[valuesToStore[i]%chords.count]+post;
        }
        
        confirmNotification.isHidden = false
        
//        let alert = UIAlertController(title: "Chords confirmed", message: "You selected : \(choice)", preferredStyle: .alert)
//        alert.addAction( UIAlertAction(title:"Ok",style: .default, handler:nil) );
//        self.present(alert,animated: true);
//
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
