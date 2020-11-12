import Foundation
import UIKit

class NoteNames {

    func getNoteName(noteNumber: Int, noteOctave: Int) -> [String] {
        let ltr =  ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let idx = abs(noteNumber) % 12
        let key = ltr[idx]
        
        let complete = key + String(noteOctave)
        
        return [complete, key]
    }
    
    
}
