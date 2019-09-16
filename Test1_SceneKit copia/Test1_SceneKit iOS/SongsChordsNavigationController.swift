//
//  SongsChordsNavigationController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 16/09/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class SongsChordsNavigationController: UINavigationController {
    
    let CHORDS_SEGUE = "chords_segue"
    let SONGS_SEGUE = "songs_segue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let setting = userDefault.integer(forKey: GAME_DEVICE_SETTINGS)
        if setting == TvSettings.withWatch.rawValue {
            performSegue(withIdentifier: CHORDS_SEGUE, sender: nil)
        }
        else {
            performSegue(withIdentifier: SONGS_SEGUE, sender: nil)
        }
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
