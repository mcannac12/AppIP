//
//  ViewController.swift
//  AppIP
//
//  Created by Marc on 2020/12/07.
//
import UIKit
class ViewController: UIViewController {
    @IBOutlet weak var bMac: UISwitch! 
    @IBOutlet weak var bIpv4: UISwitch!
    @IBOutlet weak var bIpv6: UISwitch!
    @IBOutlet weak var textIp: UITextView!
    @IBOutlet weak var labelSalut: UILabel!
    @IBAction func clicButon(_ sender: Any) {
        if labelSalut.text == "Bonjour !" {
            labelSalut.text = "Au revoir !"}
        else {labelSalut.text = "Bonjour !"}
        textIp.text = ""
        let tabNic = getInterfaces(bIpv4: bIpv4,bIpv6: bIpv6)
        for (i, ifaAdr) in tabNic.enumerated() {
            // print("\(i+1) \(ifaAdr.name) \t\(ifaAdr.mac)  \(ifaAdr.addr)")
            if ifaAdr.mac != "" {
                var addrString : String = ""
                if (bMac.isOn && (bIpv4.isOn || bIpv6.isOn))
                {
                    addrString = "\(i+1) \(ifaAdr.name) \t\(ifaAdr.mac)  \(ifaAdr.addr)"}
                else {
                    if !bMac.isOn && (bIpv4.isOn || bIpv6.isOn)
                    {
                        addrString = "\(i+1) \(ifaAdr.name) \t \(ifaAdr.addr)"}
                    else {
                        // if bMac.isOn && !bIpv4.isOn && !bIpv6.isOn
                        // cas improbable car normalement le tableau est vide
                        addrString = "\(i+1) \(ifaAdr.name) \t\(ifaAdr.mac)"
                        print(" -> ", addrString)
                    }
                }
                //                print(addrString)
                textIp.text = "\(String(textIp.text!))\n\(addrString)"
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Effectuez toute configuration supplémentaire après le chargement de la vue.
        labelSalut.text = ""
        labelSalut.text="Bonjour !"
        //        bMac.isOn=false
        //        bIpv4.isOn=false
        //        bIpv6.isOn=false
        bMac.isOn=true
        bIpv4.isOn=true
        bIpv6.isOn=true
    }
}
