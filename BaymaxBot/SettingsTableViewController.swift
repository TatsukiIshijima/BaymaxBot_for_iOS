//
//  SettingsTableViewController.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/09/29.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "設定"
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
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                
                break
            default:
                break
            }
            break
        default:
            break
        }
        return cell
    }
    
    @IBAction func switchAction(_ sender: Any) {
        if let switchButton = sender as? UISwitch {
            if let tag = swicthButtonTag(rawValue: switchButton.tag) {
                switch tag {
                case .tvPower:
                    print("TVPower")
                    break
                case .nhkChannel:
                    print("NHK")
                    break
                case .eTVCahnnel:
                    print("ETV")
                    break
                case .localCannel:
                    print("LocalTV")
                    break
                case .nihonChannel:
                    print("NihonTV")
                    break
                case .asahiChannel:
                    print("AsahiTV")
                    break
                case .tbsChannel:
                    print("TBS")
                    break
                case .tokyoChannel:
                    print("TokyoTV")
                    break
                case .fujiChannnel:
                    print("FujiTV")
                    break
                case .lightPower:
                    print("LightPower")
                    break
                case .brightUp:
                    print("BrightUp")
                    break
                case .brightDown:
                    print("BrightDown")
                    break
                case .warmer:
                    print("ColorWarmer")
                    break
                case .cooler:
                    print("ColorCooler")
                    break
                case .airconPower:
                    print("AirconPower")
                    break
                case .fanPower:
                    print("FanPower")
                    break
                case .beacon:
                    print("Beacon")
                    break
                }
            }
        }
    }
}
