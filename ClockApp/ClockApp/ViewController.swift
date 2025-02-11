import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var timerPicker: UIDatePicker!
    @IBOutlet weak var startStopButton: UIButton!
    
    var liveClockTimer: Timer?
    var countdownTimer: Timer?
    var timeLeft: TimeInterval = 0
    var audioPlayer: AVAudioPlayer?
    
    var isTimerRunning = false
    var isPlayingMusic = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerPicker.datePickerMode = .countDownTimer
        timerPicker.addTarget(self, action: #selector(timerValueChanged(_:)), for: .valueChanged)
        
        timeLeft = timerPicker.countDownDuration
        label2.text = "Time Remaining: " + timeFormatted(timeLeft)
        
        liveClockTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(updateLiveClock),
                                              userInfo: nil,
                                              repeats: true)
        updateBackgroundImage()
    }
    
    @objc func updateLiveClock() {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        label1.text = formatter.string(from: currentDate)
        updateBackgroundImage()
    }
    
    func updateBackgroundImage() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        if currentHour < 12 {
            backgroundImage.image = UIImage(named: "BackgroundDay")
        } else {
            backgroundImage.image = UIImage(named: "BackgroundNight")
        }
    }
    
    @objc func timerValueChanged(_ sender: UIDatePicker) {
        if !isTimerRunning {
            timeLeft = sender.countDownDuration
            label2.text = "Time Remaining: " + timeFormatted(timeLeft)
        }
    }
    
    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        if isPlayingMusic {
            audioPlayer?.stop()
            isPlayingMusic = false
            startStopButton.setTitle("Start Timer", for: .normal)
        }
        else if isTimerRunning {
            countdownTimer?.invalidate()
            isTimerRunning = false
            startStopButton.setTitle("Start Timer", for: .normal)
            timeLeft = timerPicker.countDownDuration
            label2.text = "Time Remaining: " + timeFormatted(timeLeft)
        }
        else {
            if timeLeft > 0 {
                isTimerRunning = true
                startStopButton.setTitle("Stop Timer", for: .normal)
                countdownTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                      target: self,
                                                      selector: #selector(updateCountdown),
                                                      userInfo: nil,
                                                      repeats: true)
            }
        }
    }
    
    @objc func updateCountdown() {
        if timeLeft > 0 {
            timeLeft -= 1
            label2.text = "Time Remaining: " + timeFormatted(timeLeft)
        } else {
            countdownTimer?.invalidate()
            isTimerRunning = false
            playSound()
            startStopButton.setTitle("Stop Music", for: .normal)
            isPlayingMusic = true
        }
    }
    
    func timeFormatted(_ totalSeconds: TimeInterval) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = (Int(totalSeconds) / 60) % 60
        let hours = Int(totalSeconds) / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func playSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error.localizedDescription)")
        }
        
        guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
