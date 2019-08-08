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
    
    
    // Sound Effects
    private var countdownPlayer: AKPlayer?
    
    
    // Songs
    private var song1: AKPlayer?
    private var song2: AKPlayer?
    private var song3: AKPlayer?
    private var song4: AKPlayer?
    private var song5: AKPlayer?
    private var song6: AKPlayer?
    private var song7: AKPlayer?
    private var song8: AKPlayer?
    private var songs: [AKPlayer]?
    
    
    // Guitars
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
    
    
    var songThread = DispatchQueue(label: "songs", qos: .userInteractive)
    var songsThreadUnlocker = DispatchQueue(label: "songsUnlocker", qos: .userInitiated)
    var songsSemaphore = DispatchSemaphore(value: 0)
    private var songChoosen: AKPlayer!
    private var isCancelled: Bool = false
    private var isResumed: Bool = true
    
    
    // This is for MainViewController
    init() {
        do {
            song1 = AKPlayer(audioFile: try findFile(str: "Songs/Give.mp3"))
            song2 = AKPlayer(audioFile: try findFile(str: "Songs/Grassy_Hill.mp3"))
            song3 = AKPlayer(audioFile: try findFile(str: "Songs/Jeremiah_s_Song.mp3"))
            song4 = AKPlayer(audioFile: try findFile(str: "Songs/Love_On_File.mp3"))
            song5 = AKPlayer(audioFile: try findFile(str: "Songs/The_Woods.mp3"))
            song6 = AKPlayer(audioFile: try findFile(str: "Songs/Then_A_Left_Turn.mp3"))
            song7 = AKPlayer(audioFile: try findFile(str: "Songs/Well_Worth_the_Wait.mp3"))
            song8 = AKPlayer(audioFile: try findFile(str: "Songs/You_Can_t_Fail.mp3"))
            
            songs = [song1!, song2!, song3!, song4!, song5!, song6!, song7!]
        }catch{
            print("AUDIOKIT ERROR! Could not find sound files")
        }
        
        AudioKit.output = AKMixer(song1!, song2!, song3!, song4!, song5!, song6!, song7!, song8!)
        
        
        songsThreadUnlocker.async {
            while true {
                if self.songs != nil {
                    let i = Int.random(in: 0..<self.songs!.count)
                    self.songChoosen = self.songs![i]
                    self.songsSemaphore.signal()
                    sleep(UInt32(self.songs![i].duration))
                }
                if self.isCancelled {
                    break
                }
            }
        }
        
        
        songThread.async {
            try! AudioKit.start()
            while true {
                if !self.isCancelled {
                    if let song = self.songChoosen {
                        song.play()
                        self.songsSemaphore.wait()
                        song.stop()
                    }
                }
                if self.isCancelled {
                    break
                }
            }
        }
    }
    
    
    // This is for GameViewController
    init(file1: String, file2: String, file3: String, file4: String) {
        
        do{
            countdownPlayer = AKPlayer(audioFile: try findFile(str: "Sound Effects/countdown.wav"))
            
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
        let file = try? AKAudioFile(readFileName: str, baseDir: .resources)
        guard file != nil else {
            throw SoundError.fileNotFound
        }
        return file!
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
    
    func stopSongs() {
        isCancelled = true
        self.songsSemaphore.signal()
        
        try! AudioKit.stop()
    }
    
    func stopGuitars() {
        try! AudioKit.stop()
    }
    
}
