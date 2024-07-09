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

        if #available(iOS 16.0, *) {
            if windowOrientation.isPortrait {
                playerHeight.constant = 300
            } else {
                playerHeight.constant = self.view.layer.bounds.height
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.playerLayer?.frame = self.videoPlayerView.bounds
            }
        }

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

