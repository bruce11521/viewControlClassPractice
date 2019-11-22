//
//  mainViewController.swift
//  viewControlClassPractice
//
//  Created by 林伯翰 on 2019/11/17.
//  Copyright © 2019 Bruce Lin. All rights reserved.
//

import UIKit
import AVFoundation

class mainViewController: UIViewController {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var songTimeSlider: UISlider!
    @IBOutlet weak var songTitleTextView: UITextView!
    
    @IBOutlet weak var nowTimeTextView: UITextView!
    @IBOutlet weak var lastTimeTextView: UITextView!
    
    @IBOutlet weak var albumTextBtn: UIButton!
    
    
    var songPlayer = AVPlayer()
    var playerItem:AVPlayerItem?
    var isPlaying = false
    var isPlayOver = false
    var SongLengthSeconds:Float64?
    var songDuration:CMTime?
    var progressTimer:Timer?
    var songCurrentNum = 0
    let songTitleAry = ["The Chainsmokers \nSomething just like this","The Chainsmokers \nCloser","Ed Sheeran\nShape of You","Lisa Miskovsky\nStill alive","Alan Walker\nFaded","K'naan\nWaving Flag","She is my sin","Team Medical Dragon\nAesthetic","Team Medical Dragon\nBlue Dragon","MONGOL800\n小さな恋のうた","米倉千尋\nWill","北島詩\n9277","傅又宣\n愛這件事情"]
    let songAry = ["TheChainsmokers-Something just like this","TheChainsmokers-Closer","EdSheeran-Shape of You","LisaMiskovsky-Still alive","AlanWalker-Faded","K'naan-WavingFlag","She is my sin","Aesthetic","Blue Dragon","MONGOL800-小さな恋のうた","米倉千尋-Will","北島詩-9277","傅又宣-愛這件事情"]
    let imageAry = ["TheChainsmokers-Something just like this","TheChainsmokers-Closer","EdSheeran-Shape of You","LisaMiskovsky-Still alive","AlanWalker-Faded","K'naan-WavingFlag","She is my sin","TeamMedicalDragon","TeamMedicalDragon","MONGOL800-小さな恋のうた","米倉千尋-Will","北島詩-9277","傅又宣-愛這件事情"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPlaySong()
         //傳送資料到musicViewController
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
    
    
    func initPlaySong(){
        let nowSong = songAry[songCurrentNum]
        songTitleTextView.text = songTitleAry[songCurrentNum]
        let sound = Bundle.main.path(forResource: nowSong, ofType: "mp3")
        playerItem = AVPlayerItem(url: URL(fileURLWithPath: sound!))
        songPlayer = AVPlayer(playerItem: playerItem!)
        songDuration = playerItem!.asset.duration
        SongLengthSeconds = CMTimeGetSeconds(songDuration!)
        lastTimeTextView.text = formateSongTime(songTime: SongLengthSeconds!)
        albumImageView.image =  UIImage(named: imageAry[songCurrentNum])
        songTimeSlider.minimumValue = 0
        songTimeSlider.maximumValue = Float(Float64(SongLengthSeconds!))
        songTimeSlider.isContinuous = false // Tap and moveOver to Change Value
        updateCurrentTime()
        
        
    }
    func transferDataToAlbumData(){
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AlbumView") as? musicViewController{
            controller.songCurrentNumber = self.songCurrentNum //傳送當前歌曲項第幾首
            self.navigationController?.pushViewController(controller, animated: true)//類似navigation的視窗
            //present(controller, animated: true, completion: nil) //從下彈出視窗
        }
        //withIdentifier: StoryBoard ID
    }
    
    
    
    func formateSongTime(songTime: Float64) -> String{
        let songLength = Int(songTime)
        let minutes = Int(songLength / 60)
        let seconds = Int(songLength % 60)
        var time = ""
            if minutes < 10{
                time = "0\(minutes)"
            }else{
                time = "\(minutes)"
            }
            if seconds < 10{
                time += ":0\(seconds)"
            }else{
                time += ":\(seconds)"
            }
            return time
        
    }
    func updateCurrentTime(){
        self.songPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
        if self.songPlayer.currentItem?.status == .readyToPlay {
        let currentTimenow = CMTimeGetSeconds(self.songPlayer.currentTime())
        self.songTimeSlider.value = Float(currentTimenow)
            self.nowTimeTextView.text = self.formateSongTime(songTime: currentTimenow)
            self.lastTimeTextView.text = self.formateSongTime(songTime: (self.SongLengthSeconds!-currentTimenow))
            if (self.SongLengthSeconds!-currentTimenow) == 0.0{  //歌曲播放完畢
                self.playBtn.setImage(UIImage(systemName: "play.fill"), for: UIControl.State.normal)
                self.songTimeSlider.value = 0.0
                self.isPlayOver = true
                
            }
         }
        })
    }
    @IBAction func albumTextBtnPress(_ sender: Any) {
        transferDataToAlbumData()
    }
    @IBAction func playBtnPress(_ sender: Any) {
        if isPlayOver{
            initPlaySong()
            songPlayer.play()
            playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            isPlaying = true
            isPlayOver = false
        }else if isPlaying{
            songPlayer.pause()
            playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlaying = false
        }else{
            songPlayer.play()
            playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            isPlaying = true
        }
        
    }
    @IBAction func nextBtnPress(_ sender: Any) {
        if songCurrentNum >= songAry.count-1 {
            songCurrentNum = 0
        }else{
            songCurrentNum += 1
        }
        initPlaySong()
        playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        albumImageView.image =  UIImage(named: imageAry[songCurrentNum])
        isPlaying = true
        songPlayer.play()
    }
    
    @IBAction func previousBtnPress(_ sender: Any) {
        if songCurrentNum == 0{
            songCurrentNum = songAry.count - 1
        }else{
            songCurrentNum -= 1
        }
        initPlaySong()
        playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        albumImageView.image =  UIImage(named: imageAry[songCurrentNum])
        isPlaying = true
        songPlayer.play()
        
    }
    
    @IBAction func songTimeSliderValueChange(_ sender: UISlider) {
        let secondsNow = Int64(songTimeSlider.value)
        let targetTime:CMTime = CMTimeMake(value: secondsNow, timescale: 1)
        // 將當前設置時間設為播放時間
        songPlayer.seek(to: targetTime)
        
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
