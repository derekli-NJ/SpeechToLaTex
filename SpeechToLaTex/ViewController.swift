//
//  ViewController.swift
//  SpeechToLaTex
//
//  Created by Derek Li on 5/11/19.
//  Copyright © 2019 Derek Li. All rights reserved.
//
import Speech
import UIKit

class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    //Mark: Properties

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    
    @IBOutlet weak var laTexDescription: UILabel!
    @IBAction func startButtonTapped(_ sender: UIButton) {
//        readFile()
        recordAndRecognizeSpeech()
    }
    
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    
    func readFile() -> Dictionary<String, String> {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "laTexSymbols", ofType: "txt")

        do {
            let data = try String(contentsOfFile: path ?? "")
            let dataArr = data.components(separatedBy: "\n")
            print (dataArr)
            
            var keys: [String] = []
            var values: [String] = []
            
            for word in dataArr {
                print (word)
                if !word.isEmpty {
                    let pair = word.components(separatedBy: " ")
                    keys.append(pair[0])
                    values.append(pair[1])
                }
            }
            return Dictionary(uniqueKeysWithValues: zip(keys, values))
        }
        catch {
            print ("error")
        }
        //return empty dictionary
        return [String: String]()
    }

//    var laTexConversionDict = [String: String] ()
    lazy var laTexConversionDict = readFile()


    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in self.request.append(buffer)}
        audioEngine.prepare();
        do {
            try audioEngine.start()
        }
        catch {
            return print (error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            //recognizer not supported for current location
            return
        }
        if !myRecognizer.isAvailable {
            //recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let spokenWords = result.bestTranscription.formattedString
                let spokenWordsArr = spokenWords.components(separatedBy: " ")
                self.detectedTextLabel.text = spokenWordsArr.last
                let laTexCode = self.ConvertToLatex(word: (spokenWordsArr.last?.lowercased())!)
                self.laTexDescription.text = laTexCode
                if laTexCode.isEmpty {
                    self.errorMessage.text = "Sorry I don't understand: " + spokenWordsArr.last!
                }
                else {
                    self.errorMessage.text = ""
                }
            }
            else if let error = error {
                print (error)
            }
        })
    }

    func ConvertToLatex(word: String) -> String{
        if let val = laTexConversionDict[word] {
            print (val)
            return val
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

