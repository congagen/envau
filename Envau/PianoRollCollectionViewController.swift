import MapKit
import UIKit
import Foundation
import RealmSwift


class PianoRollCollectionViewController: UICollectionViewController {
    
    lazy var realm = try! Realm()
    lazy var sessionData: Results<RLM_Session_14>?   = RLM_AsyncData().async_sessionData()
    lazy var beaconDataRLM: Results<RLM_BeaconData>? = RLM_AsyncData().async_beaconData()
    lazy var layers: Results<RLM_Layer_12>?          = RLM_AsyncData().async_layerData()
    lazy var keyItems: Results<RLM_Note>?            = RLM_AsyncData().async_keyData()
    
    fileprivate let protoReuseIdentifier = "PianoKeyCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    
    let layout = UICollectionViewFlowLayout()
    let blackKeys = ["C#", "D#", "F#", "G#", "A#"]
    
    let deseltedCellBgColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    let selectedCellBgColor = UIColor(red: 0.0, green: 1.0, blue: 0.2, alpha: 1.0)

    let wKeyColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    let bKeyColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    
    let keyValueNames = NoteNames()
    var selectedAnoKeyValues: [Int] { return getBeaconNotes() }
    
    @IBOutlet var cView: UICollectionView!
    
    // --------------------------------------------------------------------------------------------------
    
    
    
    func addBeaconNote(keyVal: Int)  {
        print("addBeaconNote")
        
        do {
            try realm.write {
                let newKey = RLM_Note()
                newKey.noteValue = keyVal
                sessionData![0].selectedBeacon?.activeNotes.append(newKey)
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    
    func removeBeaconNote(keyVal: Int) {
        print("removeBeaconNote")
        
        for ndata in (sessionData![0].selectedBeacon?.activeNotes)!.enumerated() {
            if ndata.element.noteValue == keyVal {
                do {
                    try realm.write {
                        sessionData![0].selectedBeacon?.activeNotes.remove(at: ndata.offset)
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        
    }
    
    
    func getSelectedBeaconKeyData() -> List<RLM_Note>? {
        
        if sessionData![0].selectedBeacon != nil {
            return (sessionData![0].selectedBeacon?.activeNotes)!
        } else {
            return nil
        }
    }
    
    
    func getBeaconNotes() -> [Int] {
        var activeN = [Int]()
        let selectData = getSelectedBeaconKeyData()
        
        if selectData != nil {
            for note in selectData! {
                activeN.append(note.noteValue)
            }
        }
        
        return activeN
    }
 
    
    func updateCell(selectedCell: PianoKeyCollectionViewCell) {
        if selectedAnoKeyValues.contains(selectedCell.keyValue) {
            removeBeaconNote(keyVal: selectedCell.keyValue)
            selectedCell.layer.borderColor = deseltedCellBgColor.cgColor

        } else {
            addBeaconNote(keyVal: selectedCell.keyValue)
            selectedCell.layer.borderColor = selectedCellBgColor.cgColor
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)! as! PianoKeyCollectionViewCell
        updateCell(selectedCell: selectedCell)
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: protoReuseIdentifier, for: indexPath) as! PianoKeyCollectionViewCell
        
        let octave = Int((indexPath.item + 12) / 12)
        let keyStr = keyValueNames.getNoteName(noteNumber: indexPath.item, noteOctave: octave)
        
        cell.layer.cornerRadius = cell.layer.frame.width * 0.5
        
        cell.keyValue = indexPath.item
        cell.colViewController = self
        cell.accessibilityHint = keyStr[1]
    
        cell.layer.borderWidth = 2
        cell.keyValueLabel.backgroundColor = UIColor.white
        
        if blackKeys.contains(keyStr[1]) {
            cell.keyValueLabel.backgroundColor = bKeyColor
            cell.keyValueLabel.textColor = UIColor.white
        } else {
            cell.keyValueLabel.backgroundColor = wKeyColor
            cell.keyValueLabel.textColor = UIColor.black
        }
        
        cell.keyValueLabel.text = keyStr[0]
        
        if selectedAnoKeyValues.contains(indexPath.item) {
            cell.layer.borderColor = selectedCellBgColor.cgColor
        } else {
            cell.layer.borderColor = deseltedCellBgColor.cgColor
        }
        
        return cell
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 127
    }

    
    func centerCollection() {
        
        if cView != nil {
            cView.scrollToItem(at: IndexPath(row: 64,section: 0),
                               at: UICollectionView.ScrollPosition.right,
                               animated: false)
        }
    }
    

    func resetPianoRoll() {
        for cell in cView.visibleCells {
            let c = cell as! PianoKeyCollectionViewCell
            
            cell.layer.borderColor = deseltedCellBgColor.cgColor
            
            if selectedAnoKeyValues.contains(c.keyValue) {
                cell.layer.borderColor = selectedCellBgColor.cgColor
            }
        }
        
        centerCollection()
    }
    
    
    override func viewDidLoad() {
        let nib = UINib(nibName: "pianoKeyCell", bundle:nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "pianoKeyCell")
        
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        layout.scrollDirection = .horizontal
        cView.collectionViewLayout = layout
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
