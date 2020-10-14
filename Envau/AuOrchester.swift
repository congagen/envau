import AudioKit
import RealmSwift
import Foundation


class AuOrchester {
    
//    let realm = try! Realm()
//    lazy var sessionData: Results<RLM_Session_14> = { self.realm.objects(RLM_Session_14.self) }()
    
    lazy var realm = try! Realm()
    lazy var sessionData: Results<RLM_Session_14>?   = RLM_AsyncData().async_sessionData()
    lazy var beaconDataRLM: Results<RLM_BeaconData>? = RLM_AsyncData().async_beaconData()
    lazy var layers: Results<RLM_Layer_12>?          = RLM_AsyncData().async_layerData()
    lazy var keyItems: Results<RLM_Note>?            = RLM_AsyncData().async_keyData()
    
    var playedKeys = [Int: Bool]()

    // Instruments
    let fmOscBankKey = AKFMOscillatorBank()
    let fmOscPreview = AKFMOscillatorBank()
    var instrumentMixer = AKMixer()
    
//    TODO: Noise
//    let wNoise = AKWhiteNoise()
//    var noiseFilter = AKResonantFilter()
    
    // Misc FX
    var fxPhaser: AKPhaser?
    var dryWetMixerPhaser: AKDryWetMixer?
    
    var fxSummingMixer: AKMixer?
    var dryWetSummingMixer: AKDryWetMixer?
    
    var summingReverb: AKCostelloReverb?
    var dryWetMixerSummingReverb: AKDryWetMixer?

    // Composite Mix
    var masterMixer = AKMixer()
    
    
// -----------------------------------------------------------------------------

    
    @objc func stopKey(_ timer: Timer) {
        if timer.isValid{
            let stopNote = timer.userInfo! as! Int
            fmOscBankKey.stop(noteNumber: MIDINoteNumber(stopNote))
            fmOscPreview.stop(noteNumber: MIDINoteNumber(stopNote))
        }
        
        timer.invalidate()
    }
    
    
    func stopKeyByNum(stopNote: Int) {
        fmOscBankKey.stop(noteNumber: MIDINoteNumber(stopNote))
        fmOscPreview.stop(noteNumber: MIDINoteNumber(stopNote))
    }
    
    
    func liftAllKeys() {
        print("liftAllKeys")
        
        for i in 0...127{
            stopKeyByNum(stopNote: i)
        }
    }
    
    
    func updateNotes() {
        print("updateNotes")
        
        if sessionData!.count > 0 {
            updateActiveKeys(
                activeBeacons: sessionData![0].beaconsInRange,
                muted: (sessionData![0].playbackPaused)
            )
        }
    }
    
    
    func toggleAudiokit(active: Bool) {
        print("toggleAudiokit")

        do {
            if active {
                try AudioKit.start()
            } else {
                try AudioKit.stop()
            }
            
        } catch {
            print("Error: \(error)")
        }
        
    }

    
    func playKey(keyVal: Int, velo: Int) {
        print("playKey")
        
        if sessionData != nil {
            if sessionData![0].holdNotes {
                if !sessionData![0].playbackPaused {
                    fmOscBankKey.play(noteNumber: MIDINoteNumber(keyVal), velocity: MIDIVelocity(velo))
                }
            } else {
                if !sessionData![0].playbackPaused && playedKeys[keyVal] == false {
                    fmOscBankKey.play(noteNumber: MIDINoteNumber(keyVal), velocity: MIDIVelocity(velo))
                }
                
                Timer.scheduledTimer(timeInterval: (sessionData![0].decayDuration),
                                     target: self,
                                     selector: #selector(stopKey),
                                     userInfo: keyVal,
                                     repeats: false)
            }
        }
        
    }

    
    func updateActiveKeys(activeBeacons: List<RLM_BeaconData>, muted: Bool) {
        print("updateActiveKeys")
        
        var notesToPlay = [Int: [Int]]()
        var velo = 0
        
        for b in activeBeacons {
            if !b.deleted {
                for k in b.activeNotes {
                    let pitchAmp = abs(127 - k.noteValue) + 1
                    
                    if sessionData != nil {
                        if sessionData![0].ampFromDistance && sessionData![0].holdNotes {
                            let divDistance = abs( Double(b.currentDistance + 0.001) / Double(b.activeRadius + 0.001) )
                            velo = Int(abs(pitchAmp - (pitchAmp * divDistance)))
                        } else {
                            velo = pitchAmp
                        }
                    }
                    
                    if !notesToPlay.keys.contains(k.noteValue) {
                        notesToPlay[k.noteValue] = [velo]
                    } else {
                        notesToPlay[k.noteValue]?.append(velo)
                    }
                }
            }
        }
    
        liftAllKeys()
      
        for n in notesToPlay.keys {
            if sessionData != nil {
                
                if sessionData![0].avgVeloFromDuplicateNotes {
                    let avgVel = (notesToPlay[n]?.reduce(0, +))! / (notesToPlay[n]?.count)!
                    playKey(keyVal: n, velo: avgVel)
                } else {
                    playKey(keyVal: n, velo: (notesToPlay[n]?.max())!)
                }
                
            }
        }
        
        for k in 0...256 {
            playedKeys[k]! = notesToPlay.keys.contains(k)
        }
    }
  
    
    func updateOrchestra() {
        print("updateOrchestra")
        
        if sessionData != nil {
            if (sessionData!.count > 0) {
                
                if !sessionData![0].playbackPaused {
                    instrumentMixer.volume = sessionData![0].masterVolume
                } else {
                    instrumentMixer.volume = 0
                }
                
                fxPhaser?.notchWidth = sessionData![0].audioFxAmoutA
                dryWetSummingMixer?.balance = sessionData![0].dryWetFxMix

                summingReverb?.rampDuration = 2.0
                summingReverb?.feedback = 0.9
                dryWetMixerSummingReverb?.balance = sessionData![0].reverbAmount
                
                fmOscBankKey.attackDuration = sessionData![0].attackDuration
                fmOscPreview.attackDuration = sessionData![0].attackDuration

                fmOscBankKey.decayDuration = sessionData![0].decayDuration
                fmOscPreview.decayDuration = sessionData![0].decayDuration

                fmOscBankKey.releaseDuration = sessionData![0].releaseDuration
                fmOscPreview.releaseDuration = sessionData![0].releaseDuration
            }
        }
    }
    
    
    init() {
        print("init")

        AKSettings.playbackWhileMuted = true
        
        instrumentMixer = AKMixer(fmOscBankKey)
        
        fxPhaser = AKPhaser(instrumentMixer)
        fxPhaser?.lfoBPM = 24
        fxPhaser?.notchWidth = 5000
        fxPhaser?.feedback = 0.5

        // FX Amt
        dryWetSummingMixer = AKDryWetMixer(instrumentMixer, fxPhaser!)
        
        // Stereo
        summingReverb = AKCostelloReverb(dryWetSummingMixer)
        dryWetMixerSummingReverb = AKDryWetMixer(dryWetSummingMixer!, summingReverb!)
        AudioKit.output = dryWetMixerSummingReverb
        
        for i in 0...256 {
            playedKeys[i] = false
        }
        
        do {
            try AudioKit.start()
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    
}
