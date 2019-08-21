//
//  Guitar.swift
//  Test
//
//  Created by Gennaro Giaquinto on 13/07/2019.
//  Copyright © 2019 Francesco Chiarello. All rights reserved.
//

import Foundation
import AudioKit

enum GuitarError: Error {
    case fileNotFound(String)
}

class Guitar {
    
//    chord property, when we call on this the play method, il plays the assigned sampled chord
    let chord: AKPlayer?
    
//    Receives as a parameter only the file that contains the chord sample. The file must be in the same
    //    folder as the source file (baseDir: .resources)
    init(file: String) throws{
        let file = try? AKAudioFile(readFileName: "Chords/" + file, baseDir: .resources)
        guard file != nil else{
            throw GuitarError.fileNotFound("File: \(file) not found!")
        }
        chord = AKPlayer(audioFile: file!)
    }
    
    
    func playGuitar() {
        if chord != nil{
            chord!.stop()
            chord!.play()
        }
    }
    
    func resetGuitar() {
        if let _ = chord {
            chord!.stop()
        }
    }
    
    
}
