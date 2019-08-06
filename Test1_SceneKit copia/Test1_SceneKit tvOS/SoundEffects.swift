//
//  SoundEffects.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 06/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import Foundation
import AudioKit

enum SoundError: Error {
    case fileNotFound
}

class SoundEffect {
    
    private var file: AKAudioFile?
    
    private var countdownPlayer: AKPlayer?
    
    
    
    
    private var guitar11: Guitar?
    private var guitar21: Guitar?
    private var guitar31: Guitar?
    private var guitar41: Guitar?
    private var guitar12: Guitar?
    private var guitar22: Guitar?
    private var guitar32: Guitar?
    private var guitar42: Guitar?
    
    private var flag1 = false
    private var flag2 = false
    private var flag3 = false
    private var flag4 = false
    
    init(file1: String, file2: String, file3: String, file4: String) {
        
        do{
            countdownPlayer = AKPlayer(audioFile: try findFile(str: "countdown.wav"))
            
            
            guitar11 = try Guitar(file: file1)
            guitar21 = try Guitar(file: file2)
            guitar31 = try Guitar(file: file3)
            guitar41 = try Guitar(file: file4)
            guitar12 = try Guitar(file: file1)
            guitar22 = try Guitar(file: file2)
            guitar32 = try Guitar(file: file3)
            guitar42 = try Guitar(file: file4)
        }catch{
            print("AUDIOKIT ERROR! Could not find sound files")
        }
        
        
        AudioKit.output = AKMixer(guitar11?.chord, guitar21?.chord, guitar31?.chord, guitar41?.chord, guitar12?.chord, guitar22?.chord, guitar32?.chord, guitar42?.chord, countdownPlayer)
        do{
            try AudioKit.start()
        }catch{
            print("AUDIOKIT ERROR! Motor couldn't start!")
        }
    }
    
    private func findFile(str: String) throws -> AKAudioFile {
        let file = try? AKAudioFile(readFileName: "Sound Effects/" + str, baseDir: .resources)
        guard file != nil else {
            throw SoundError.fileNotFound
        }
        return file!
    }
    
    func initGuitars(file1: String, file2: String, file3: String, file4: String) {
        
        
    }
    
    func countdown() {
        if countdownPlayer != nil{
            countdownPlayer!.stop()
            countdownPlayer!.play()
        }
    }
    
    func guitar1() {
        if !self.flag1{
            self.guitar11!.playGuitar()
            self.flag1 = true
        }
        else{
            self.guitar12!.playGuitar()
            self.flag1 = false
        }
    }
    
    func guitar2() {
        if !self.flag2{
            self.guitar21!.playGuitar()
            self.flag2 = true
        }
        else{
            self.guitar22!.playGuitar()
            self.flag2 = false
        }
    }
    
    func guitar3() {
        if !self.flag3{
            self.guitar31!.playGuitar()
            self.flag3 = true
        }
        else{
            self.guitar32!.playGuitar()
            self.flag3 = false
        }
    }
    
    func guitar4() {
        if !self.flag4{
            self.guitar41!.playGuitar()
            self.flag4 = true
        }
        else{
            self.guitar42!.playGuitar()
            self.flag4 = false
        }
    }
    
}
