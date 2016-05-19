import UIKit
import Foundation
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingDurationLabel: UILabel!

    var audioRecorder:AVAudioRecorder!
    var timer = NSTimer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        stopRecordingButton.enabled = false
        recordingDurationLabel.text = "0.0"
        recordingDurationLabel.alpha = 0
    }

    @IBAction func recordAudio(sender: AnyObject) {
        recordButton.enabled = false
        stopRecordingButton.enabled = true
        recordingLabel.text = "Recording in Progress..."

        // Directory path as String
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)

        // Setup session to play and record
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)

        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()

        // Show recording duration if recording
        if audioRecorder.recording {
            recordingDurationLabel.alpha = 1
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(RecordSoundsViewController.updateRecordingDuration), userInfo: nil, repeats: true)
        }
    }

    @IBAction func stopRecording(sender: AnyObject) {
        timer.invalidate()
        stopRecordingButton.enabled = false
        recordButton.enabled = true
        recordingLabel.text = "Tap to Record"

        audioRecorder.stop()
        let audioSession =  AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio Recorder Finished Saving")
        if flag {
            performSegueWithIdentifier("stopRecording", sender: audioRecorder.url)
        } else {
            print("Saving audio failed")
        }
    }

    func updateRecordingDuration() {
        recordingDurationLabel.text = (NSString(format: "%.1f", audioRecorder.currentTime)) as String
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            let recordedAudioURL = sender as! NSURL
            playSoundsVC.recordedAudio = recordedAudioURL
        }
    }
}
