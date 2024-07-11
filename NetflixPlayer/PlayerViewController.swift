//
//  ViewController.swift
//  NetflixPlayer
//
//  Created by Janvi Arora on 07/07/24.
//

import UIKit
import AVKit

class PlayerViewController: UIViewController {

    @IBOutlet weak var playerHeight: NSLayoutConstraint!
    @IBOutlet weak var videoPlayerView: UIView!

    @IBOutlet weak var controlsStack: UIStackView!

    @IBOutlet weak var playBackward: UIImageView! {
        didSet {
            self.playBackward.isUserInteractionEnabled = true
            self.playBackward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(play10SecBackward)))
        }
    }

    @IBOutlet weak var playForward: UIImageView! {
        didSet {
            self.playForward.isUserInteractionEnabled = true
            self.playForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(play10SecForward)))
        }
    }

    @IBOutlet weak var playPause: UIImageView! {
        didSet {
            self.playPause.isUserInteractionEnabled = true
            self.playPause.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePlayPause)))
        }
    }

    @IBOutlet weak var timerStack: UIStackView!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var totalTime: UILabel!

    @IBOutlet weak var slider: UISlider! {
        didSet {
            self.slider.addTarget(self, action: #selector(upadeOnSlide), for: .valueChanged)
        }
    }

    @IBOutlet weak var fullScreenImageView: UIImageView! {
        didSet {
            self.fullScreenImageView.isUserInteractionEnabled = true
            self.fullScreenImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleFullScreen)))
        }
    }

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var seekSlider: Bool = false

    private var windowOrientation: UIInterfaceOrientation? {
        return self.view.window?.windowScene?.interfaceOrientation
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        setVideoPlayer()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        guard let windowOrientation else { return }

        if windowOrientation.isPortrait {
            playerHeight.constant = 300
        } else {
            playerHeight.constant = self.view.layer.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playerLayer?.frame = self.videoPlayerView.bounds
        }

    }

    private func setVideoPlayer() {
        guard let url = URL(string: Constants.videoURL) else { return }

        if player == nil {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = videoPlayerView.bounds
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.addSublayer(controlsStack.layer)
            playerLayer?.addSublayer(timerStack.layer)
            if let playerLayer {
                videoPlayerView.layer.addSublayer(playerLayer)
            }
            player?.play()
        }
        addObserver()
    }

    private func addObserver() {
        let interval = CMTime(seconds: 0.3, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { elapsedTime in
            self.updatePlayerTimer()
        })
    }

    private func updatePlayerTimer() {
        guard let currTime = player?.currentTime() else { return }
        guard let duration = player?.currentItem?.duration else { return }

        let currTimeInSeconds = CMTimeGetSeconds(currTime)
        let durationInSeconds = CMTimeGetSeconds(duration)

        if !seekSlider {
            slider.value = Float(currTimeInSeconds/durationInSeconds)
        }

        currentTime.text = "\(Int(currTimeInSeconds))"
        totalTime.text = "\(Int(durationInSeconds))"
    }

    @objc
    private func play10SecBackward() {
        guard let currTime = player?.currentTime() else { return }
        let updatedValue = CMTimeGetSeconds(currTime).advanced(by: -10)
        let seekTime = CMTime(value: CMTimeValue(updatedValue), timescale: 1)
        player?.seek(to: seekTime, completionHandler: { completed in
            if completed {
                self.seekSlider = false
            }
        })
    }

    @objc
    private func play10SecForward() {
        guard let currTime = player?.currentTime() else { return }
        let updatedValue = CMTimeGetSeconds(currTime).advanced(by: 10)
        let seekTime = CMTime(value: CMTimeValue(updatedValue), timescale: 1)
        player?.seek(to: seekTime, completionHandler: { completed in
            if completed {
                self.seekSlider = false
            }
        })
    }

    @objc
    private func togglePlayPause() {
        if player?.timeControlStatus == .playing {
            playPause.image = UIImage(systemName: "pause.fill")
            player?.pause()
        } else {
            playPause.image = UIImage(systemName: "play.fill")
            player?.play()
        }
    }

    @objc
    private func upadeOnSlide() {
        seekSlider = true
        guard let duration = player?.currentItem?.duration else { return }
        let updatedSliderValue = Float64(slider.value) * (CMTimeGetSeconds(duration))

        if !updatedSliderValue.isNaN {
            let seekTime = CMTime(value: CMTimeValue(updatedSliderValue), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { completed in
                if completed {
                    self.seekSlider = false
                }
            })
        }
    }

    @objc
    private func toggleFullScreen() {
        if #available(iOS 16.0, *) {
            guard let windowScene = view.window?.windowScene else { return }
            if windowScene.interfaceOrientation == .portrait {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            } else {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        } else {
            if UIDevice.current.orientation == .portrait {
                let orientation = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
            } else {
                let orientation = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
            }
        }
    }
}

