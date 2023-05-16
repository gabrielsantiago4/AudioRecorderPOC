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

    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    var fileName: String = "audioFile.m4a"

    var isRecording = false
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorder()
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }



    func setupRecorder() {
        let audioFileName = getDocumentsDirectory().appendingPathComponent(fileName)

        let recordSettings = [

            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.2,
            AVNumberOfChannelsKey: 2,
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
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 5.0

        } catch {
            print(error)
        }

    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
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
            playButton.setTitle("Play", for: .normal)
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
        result
    }

    func requestDidComplete(_ request: SNRequest) {
        print("processou")
    }


}

