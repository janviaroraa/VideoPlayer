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

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        setVideoPlayer()
    }

    private func setVideoPlayer() {
        guard let url = URL(string: Constants.videoURL) else { return }

        if player == nil {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = videoPlayerView.bounds
            playerLayer?.videoGravity = .resizeAspectFill
            if let playerLayer {
                videoPlayerView.layer.addSublayer(playerLayer)
            }
        }
        player?.play()
    }

}

