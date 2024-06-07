//
//  AudioObservable.swift
//  FindTheRocks
//
//  Created by Sidi Praptama Aurelius Nurhalim on 07/06/24.
//

import Foundation
import AVFoundation

@Observable
class AudioObservable {
    var playerMusic: AVAudioPlayer?
    var playerSFX: AVAudioPlayer?
    
    func playClick() {
        guard let path = Bundle.main.path(forResource: "click", ofType: ".mp3") else {
          return
        }
          
          let url = URL(fileURLWithPath: path)

        do {
            self.playerSFX = try AVAudioPlayer(contentsOf: url)
            self.playerSFX?.currentTime = 0
            self.playerSFX?.volume = 3
            self.playerSFX?.play()
        } catch {
          print("Failed to load the sound: \(error)")
        }
        playerSFX?.play()
    }
    
    func playKerching() {
        guard let path = Bundle.main.path(forResource: "kerching", ofType: ".mp3") else {
          return
        }
          
          let url = URL(fileURLWithPath: path)

        do {
            self.playerSFX = try AVAudioPlayer(contentsOf: url)
            self.playerSFX?.currentTime = 0
            self.playerSFX?.volume = 3
            self.playerSFX?.play()
        } catch {
          print("Failed to load the sound: \(error)")
        }
        playerSFX?.play()
    }
    
    func playWin() {
        guard let path = Bundle.main.path(forResource: "winner", ofType: ".mp3") else {
          return
        }
          
          let url = URL(fileURLWithPath: path)

        do {
            self.playerSFX = try AVAudioPlayer(contentsOf: url)
            self.playerSFX?.currentTime = 0
            self.playerSFX?.volume = 3
            self.playerSFX?.play()
        } catch {
          print("Failed to load the sound: \(error)")
        }
        playerSFX?.play()
    }
    
    func playBGMusic() {
      guard let path = Bundle.main.path(forResource: "background-music-funk", ofType: ".mp3") else {
        return
      }
        
        let url = URL(fileURLWithPath: path)

      do {
          self.playerMusic = try AVAudioPlayer(contentsOf: url)
          self.playerMusic?.numberOfLoops = -1 // Loop indefinitely
          self.playerMusic?.currentTime = 0
          self.playerMusic?.volume = 3
          self.playerMusic?.play()
      } catch {
        print("Failed to load the sound: \(error)")
      }
      playerMusic?.play()
    }
}
