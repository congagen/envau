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
    let engine = AudioEngine()

    // Instruments
    let fmOscBankKey = Synth()
    let fmOscPreview = Synth()
    var instrumentMixer = Mixer()
    
//    TODO: Noise
//    let wNoise = AKWhiteNoise()
//    var noiseFilter = AKResonantFilter()
    
    // Misc FX
    var fxPhaser: Phaser?
    var dryWetMixerPhaser: DryWetMixer?
    
    var fxSummingMixer: Mixer?
    var dryWetSummingMixer: DryWetMixer?
    
    var summingReverb: CostelloReverb?
    var dryWetMixerSummingReverb: DryWetMixer?

    // Composite Mix
    var masterMixer = Mixer()
    
    var currentNotesPlaying = [Int: [Int]]()
    
    
// -----------------------------------------------------------------------------

    
    @objc func stopKey(_ timer: Timer) {
        print("stopKey")
        
        if timer.isValid{
            let stopNote = timer.userInfo! as! Int
            fmOscBankKey.stop(noteNumber: MIDINoteNumber(stopNote))
            fmOscPreview.stop(noteNumber: MIDINoteNumber(stopNote))
        }
        
        timer.invalidate()
    }
    
    
    func stopKeyByNum(stopNote: Int) {
        print("stopKeyByNum")
        
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
                try engine.start()
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
                            let divDistance = abs( Double(Double(b.currentDistance) + Double(0.001)) / Double(Double(b.activeRadius) + Double(0.001)) )
                            velo = Int(abs(pitchAmp - (pitchAmp * Int(divDistance))))
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
        
        for k in 0...127 {
            if !(notesToPlay.keys.contains(k)) {
                stopKeyByNum(stopNote: k)
                currentNotesPlaying[k] = []
            }
        }
        
//        for ub in beaconDataRLM! {
//            if !activeBeacons.contains(ub) {
//                for k in ub.activeNotes {
//                    if !(notesToPlay.keys.contains(k.noteValue)) {
//                        stopKeyByNum(stopNote: k.noteValue)
//                        currentNotesPlaying[k.noteValue] = []
//                    }
//                }
//            }
//        }
    
        //liftAllKeys()
      
        for n in notesToPlay.keys {
            if sessionData != nil {
                
//                if sessionData![0].avgVeloFromDuplicateNotes {
//                    let avgVel = (notesToPlay[n]?.reduce(0, +))! / (notesToPlay[n]?.count)!
//                    playKey(keyVal: n, velo: avgVel)
//                } else {
//
//                }
                if currentNotesPlaying[n] == [] {
                    playKey(keyVal: n, velo: (notesToPlay[n]?.max())!)
                    currentNotesPlaying[n] = notesToPlay[n]
                } else {
                    // TODO: Only update velocity?
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
                    instrumentMixer.volume = Float(sessionData![0].masterVolume)
                } else {
                    instrumentMixer.volume = 0
                }
                
                fxPhaser?.notchWidth = Float(sessionData![0].audioFxAmoutA)
                dryWetSummingMixer?.balance = Float(sessionData![0].dryWetFxMix)

                //summingReverb?.rampDuration = Float(2.0)
                //summingReverb?.$amplitude.ramp(to: 0.9, duration: 1.2)
                
                summingReverb?.feedback = Float(0.9)
                dryWetMixerSummingReverb?.balance = Float(sessionData![0].reverbAmount)
                
                fmOscBankKey.attackDuration = Float(sessionData![0].attackDuration)
                fmOscPreview.attackDuration = Float(sessionData![0].attackDuration)

                fmOscBankKey.decayDuration = Float(sessionData![0].decayDuration)
                fmOscPreview.decayDuration = Float(sessionData![0].decayDuration)

                fmOscBankKey.releaseDuration = Float(sessionData![0].releaseDuration)
                fmOscPreview.releaseDuration = Float(sessionData![0].releaseDuration)
            }
        }
    }
    
    
    init() {
        print("init")

        //AKSettings.playbackWhileMuted = true
        //Settings.playbackWhileMuted = true
        
        instrumentMixer = Mixer(fmOscBankKey)
        
        //fmOscBankKey.au.setWavetable([AUValue(1)], index: 1)
        
//        fmOscBankKey.decayDuration = 1000
//        fmOscBankKey.sustainLevel = 1000
//        fmOscBankKey.releaseDuration = 1000
        
        fxPhaser = Phaser(instrumentMixer)
        fxPhaser?.lfoBPM = 24
        fxPhaser?.notchWidth = 5000
        fxPhaser?.feedback = 0.5

        // FX Amt
        dryWetSummingMixer = DryWetMixer(instrumentMixer, fxPhaser!)
        
        
        // Stereo
        //summingReverb = CostelloReverb(dryWetSummingMixer)
        summingReverb = CostelloReverb(dryWetSummingMixer! as Node)
        
        
        dryWetMixerSummingReverb = DryWetMixer(dryWetSummingMixer!, summingReverb!)
        
        
        engine.output = dryWetMixerSummingReverb
        
        for i in 0...256 {
            playedKeys[i] = false
        }
        
        do {
            try engine.start()
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    
}
