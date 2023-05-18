//
//  ViewController.swift
//  AudioRecorderPOC
//
//  Created by Gabriel Santiago on 15/05/23.
//

import UIKit
import AVFoundation
import SoundAnalysis

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var nickelbackButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultText: UILabel!


    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    var fileName: String = "audioFile.m4a"

    var isRecording = false
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()

        recordingSession = AVAudioSession.sharedInstance()


        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                print("ALLOWED:", allowed)
                self.setupRecorder()
            }
        } catch {
            // failed to record!
        }




    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }


    func setupRecorder() {
        let audioFileName = getDocumentsDirectory().appendingPathComponent(fileName)

        let recordSettings = [

            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,

        ] as [String: Any]

        do{
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {

            print(error)
        }
    }

    func setupPlayer() {
        
        let audioFileName = getDocumentsDirectory().appendingPathComponent(fileName)

        do{
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileName)
            audioPlayer.delegate = self
//            audioPlayer.prepareToPlay()
            audioPlayer.volume = 80.0

        } catch {
            print(error.localizedDescription)
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Preview", for: .normal)
        isPlaying = false
    }


    @IBAction func play(_ sender: Any) {
        if isPlaying == false {
            setupPlayer()

            audioPlayer.play()
            playButton.setTitle("Stop", for: .normal)
            recordButton.isEnabled = false
            isPlaying = true
        } else {
            audioPlayer.stop()
            playButton.setTitle("Preview", for: .normal)
            recordButton.isEnabled = true
            isPlaying = false
        }
    }

    @IBAction func record(_ sender: Any) {
        if isRecording == false {
            audioRecorder.record()
            recordButton.setTitle("Stop", for: .normal)
            playButton.isEnabled = false
            isRecording = true
        } else {
            audioRecorder.stop()
            recordButton.setTitle("Record", for: .normal)
            playButton.isEnabled = false
            isRecording = false
        }
    }


    @IBAction func analyzeAudio(_ sender: Any) {
        do {
            let fileAnalyzer = try SNAudioFileAnalyzer(url: getDocumentsDirectory().appendingPathComponent(fileName))
            let request = try SNClassifySoundRequest(mlModel: NicklebackClassifier().model)
            try fileAnalyzer.add(request, withObserver: self)
            fileAnalyzer.analyze()
        } catch {
            print(error)
        }
    }
}

extension ViewController: SNResultsObserving {
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        guard let classification = result.classifications.first else { return }
        DispatchQueue.main.async {
            self.resultText.text = classification.identifier

            if self.resultText.text == "Totally Nickelback"{
                self.imageView.image = UIImage(named: "chadkroeger")
            } else if self.resultText.text == "Not Nickelback"{
                self.imageView.image = UIImage(named: "adamdriver")
            }
        }
    }

    func requestDidComplete(_ request: SNRequest) {
        print("processou")
    }
}

