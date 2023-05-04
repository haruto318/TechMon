//
//  BattleViewController.swift
//  TechMon
//
//  Created by Haruto Hamano on 2023/05/04.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPBar: UIProgressView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPBar: UIProgressView!
    
    @IBOutlet var shinkaButton: UIButton!

    var player: Player!
    var enemy: Enemy!
    
    var enemyAttackTimer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()

        playerHPBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
        enemyHPBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
        
        player = Player(name: "ルフィ", imageName: "rufy.png", attackPoint: 10, fireAttackPoint: 300, maxHP: 100, maxTP: 1000, ShinkaImage: "gearFourth.png")
        enemy = Enemy(name: "黒ひげ", imageName: "kurohige.png", attackPoint: 10, maxHP: 300)
        
        playerNameLabel.text = player.name
        playerImageView.image = player.image
        playerTPLabel.text = "\(String(player.currentTP)) / \(String(player.maxTP))"
        
        enemyNameLabel.text = enemy.name
        enemyImageView.image = enemy.image
        
        shinkaButton.isEnabled = false
        
        updataUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TechMonManager.playBGM(fileName: "BGM_battle001")
        
        enemyAttackTimer = Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(enemyAttack),
            userInfo: nil,
            repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TechMonManager.stopBGM()
    }
    
    func updataUI(){
        if player.currentHP <= player.maxHP * 0.3{
            playerHPLabel.textColor = UIColor.red
        }
        playerHPBar.progress = player.currentHP / player.maxHP
        enemyHPBar.progress = enemy.currentHP / enemy.maxHP
        
        if player.currentTP >= player.maxTP {
            shinkaButton.isEnabled = true
        }
    }
    
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool){
        TechMonManager.vanishAnimation(imageView: vanishImageView)
        TechMonManager.stopBGM()
        enemyAttackTimer.invalidate()
        
        var finishMessage: String = ""
        if isPlayerWin{
            TechMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "ルフィの勝利！！"
        } else {
            TechMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "ルフィの敗北…"
        }
        
        let alert = UIAlertController(
            title: "バトル終了",
            message: finishMessage,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
    @IBAction func attackAction(){
        TechMonManager.damageAnimation(imageView: enemyImageView)
        TechMonManager.playSE(fileName: "SE_attack")
        
        enemy.currentHP -= player.attackPoint
        
        player.currentTP += 5
        if player.currentTP >= player.maxTP{
            player.currentTP = player.maxTP
        }
        
        playerTPLabel.text = "\(String(player.currentTP)) / \(String(player.maxTP))"
        
        updataUI()
        
        if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    @IBAction func chargeAction(){
        TechMonManager.playSE(fileName: "SE_charge")
        
        player.currentTP += 20
        if player.currentTP >= player.maxTP{
            player.currentTP = player.maxTP
        }
        
        playerTPLabel.text = "\(String(player.currentTP)) / \(String(player.maxTP))"
        
        updataUI()
    }
    
    @IBAction func fireAction(){
        if player.currentTP >= player.maxTP{
            TechMonManager.damageAnimation(imageView: enemyImageView)
            TechMonManager.playSE(fileName: "SE_fire")
            
            player.attackPoint = player.fireAttackPoint
            
            playerImageView.image = player.shinkaImage
            playerNameLabel.text = player.name + " (ギア4)"
            
            player.currentTP = 0
        }
        
        playerTPLabel.text = "\(String(player.currentTP)) / \(String(player.maxTP))"
        
        updataUI()
        
        if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    @objc func enemyAttack(){
        TechMonManager.damageAnimation(imageView: playerImageView)
        TechMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= enemy.attackPoint
        
        updataUI()
        
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }
    }
    

}
