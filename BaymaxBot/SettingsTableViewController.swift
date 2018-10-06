//
//  SettingsTableViewController.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/09/29.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {
    
    enum swicthButtonTag: Int {
        case tvPower = 0
        case nhkChannel = 1
        case eTVCahnnel = 2
        case localCannel = 3
        case nihonChannel = 4
        case asahiChannel = 5
        case tbsChannel = 6
        case tokyoChannel = 7
        case fujiChannnel = 8
        case lightPower = 9
        case brightUp = 10
        case brightDown = 11
        case warmer = 12
        case cooler = 13
        case airconPower = 14
        case fanPower = 15
        case beacon = 16
    }
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var tvPowerSwitch: UISwitch!
    @IBOutlet weak var nhkSwitch: UISwitch!
    @IBOutlet weak var etvSwitch: UISwitch!
    @IBOutlet weak var localSwitch: UISwitch!
    @IBOutlet weak var nihonSwitch: UISwitch!
    @IBOutlet weak var asahiSwitch: UISwitch!
    @IBOutlet weak var tbsSwitch: UISwitch!
    @IBOutlet weak var tokyoSwitch: UISwitch!
    @IBOutlet weak var fujiSwitch: UISwitch!
    @IBOutlet weak var lightPowerSwitch: UISwitch!
    @IBOutlet weak var brightUpSwitch: UISwitch!
    @IBOutlet weak var brightDownSwitch: UISwitch!
    @IBOutlet weak var lightWarmerSwitch: UISwitch!
    @IBOutlet weak var lightCoolerSwitch: UISwitch!
    @IBOutlet weak var airconPowerSwitch: UISwitch!
    @IBOutlet weak var fanPowerSwitch: UISwitch!
    @IBOutlet weak var beaconSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "デバッグ"
        
        self.ref = Database.database().reference()
        setSwitchButtonbyGrandson(rootPath: "tv", childPath: "channel", grandSonPath: "nhk", switchButton: nhkSwitch)
        setSwitchButtonbyGrandson(rootPath: "tv", childPath: "channel", grandSonPath: "nhk_e", switchButton: etvSwitch)
        setSwitchButtonbyGrandson(rootPath: "tv", childPath: "channel", grandSonPath: "local", switchButton: localSwitch)
        setSwitchButtonbyGrandson(rootPath: "tv", childPath: "channel", grandSonPath: "nihon", switchButton: nihonSwitch)
        setSwitchButtonbyGrandson(rootPath: "tv", childPath: "channel", grandSonPath: "asahi", switchButton: asahiSwitch)
        setSwitchButtonbyGrandson(rootPath: "tv", childPath: "channel", grandSonPath: "tbs", switchButton: tbsSwitch)
        setSwitchButtonbyGrandson(rootPath: "tv", childPath: "channel", grandSonPath: "tokyo", switchButton: tokyoSwitch)
        setSwitchButtonbyGrandson(rootPath: "tv", childPath: "channel", grandSonPath: "fuji", switchButton: fujiSwitch)
        setSwicthButtonbyChildren(rootPath: "light", childPath: "power", switchButton: lightPowerSwitch)
        setSwicthButtonbyChildren(rootPath: "light", childPath: "bright_up", switchButton: brightUpSwitch)
        setSwicthButtonbyChildren(rootPath: "light", childPath: "bright_down", switchButton: brightDownSwitch)
        setSwicthButtonbyChildren(rootPath: "light", childPath: "warmer", switchButton: lightWarmerSwitch)
        setSwicthButtonbyChildren(rootPath: "light", childPath: "cooler", switchButton: lightCoolerSwitch)
        setSwicthButtonbyChildren(rootPath: "aircon", childPath: "power", switchButton: airconPowerSwitch)
        setSwicthButtonbyChildren(rootPath: "fan", childPath: "power", switchButton: fanPowerSwitch)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 9
        case 1:
            return 5
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell
    }
    
    func setSwicthButtonbyChildren(rootPath: String, childPath: String, switchButton: UISwitch) {
        self.ref.child(rootPath).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let flag = value?[childPath] as? Bool ?? false
            switchButton.setOn(flag, animated: false)
        })
    }
    
    func setSwitchButtonbyGrandson(rootPath: String, childPath: String, grandSonPath: String, switchButton: UISwitch) {
        self.ref.child(rootPath).child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let flag = value?[grandSonPath] as? Bool ?? false
            switchButton.setOn(flag, animated: false)
        })
    }
    
    @IBAction func switchAction(_ sender: Any) {
        if let switchButton = sender as? UISwitch {
            if let tag = swicthButtonTag(rawValue: switchButton.tag) {
                switch tag {
                case .tvPower:
                    self.ref.child("tv/power").setValue(tvPowerSwitch.isOn)
                    break
                case .nhkChannel:
                    self.ref.child("tv/channel/nhk").setValue(nhkSwitch.isOn)
                    break
                case .eTVCahnnel:
                    self.ref.child("tv/channel/nhk_e").setValue(etvSwitch.isOn)
                    break
                case .localCannel:
                    self.ref.child("tv/channel/local").setValue(localSwitch.isOn)
                    break
                case .nihonChannel:
                    self.ref.child("tv/channel/nihon").setValue(nihonSwitch.isOn)
                    break
                case .asahiChannel:
                    self.ref.child("tv/channel/asahi").setValue(asahiSwitch.isOn)
                    break
                case .tbsChannel:
                    self.ref.child("tv/channel/tbs").setValue(tbsSwitch.isOn)
                    break
                case .tokyoChannel:
                    self.ref.child("tv/channel/tokyo").setValue(tokyoSwitch.isOn)
                    break
                case .fujiChannnel:
                    self.ref.child("tv/channel/fuji").setValue(fujiSwitch.isOn)
                    break
                case .lightPower:
                    self.ref.child("light/power").setValue(lightPowerSwitch.isOn)
                    break
                case .brightUp:
                    self.ref.child("light/bright_up").setValue(brightUpSwitch.isOn)
                    break
                case .brightDown:
                    self.ref.child("light/bright_down").setValue(brightDownSwitch.isOn)
                    break
                case .warmer:
                    self.ref.child("light/warmer").setValue(lightWarmerSwitch.isOn)
                    break
                case .cooler:
                    self.ref.child("light/cooler").setValue(lightCoolerSwitch.isOn)
                    break
                case .airconPower:
                    self.ref.child("aircon/power").setValue(airconPowerSwitch.isOn)
                    break
                case .fanPower:
                    self.ref.child("fan/power").setValue(fanPowerSwitch.isOn)
                    break
                case .beacon:
                    print("Beacon")
                    break
                }
            }
        }
    }
}
