//
//  calculIp.swift
//  AppIP
//
//  Created by Marc on 2020/12/07.
//
//
//import Foundation
import UIKit
// _______________________________________
func getInterfaces(bIpv4: UISwitch,bIpv6: UISwitch) -> [(name : String, addr: String, mac : String)] {
    var tabNic = [(name : String, addr: String, mac : String)]()
    // Get list of all interfaces on the local machine:
    var listeAdr : UnsafeMutablePointer<ifaddrs>?
    // traitement d'erreurs
    guard
        getifaddrs(&listeAdr) == 0,
        let premAdr = listeAdr
    else { return [] }
    
    // dicNameToMac est le dictionnaire des interfaces et de leur adresse mac
    // Dans un dictionnaire pas d'indice mais une clé (contrairement au tableau), à une clé, on associe une valeur.
    // Chaque clé du dictionnaire doit être du même type, de même chaque valeur doit être du même type,
    //  mais le type des clés peut être différent du type des valeurs.
    var dicNameToMac = [ String: String ]() // nom de l'interface : son adresse MAC
    
    // Pour chaque interface NIC (Netwwork Interface Card) ...
    // $0 est un raccourci pour signifier "premier argument" dans un bloc de fonctionnalité autonome.
    for curseur in sequence(first: premAdr, next: { $0.pointee.ifa_next }) {
        let ifaFlags = Int32(curseur.pointee.ifa_flags)
        if let ifaAddr = curseur.pointee.ifa_addr {
            let ifaName = String(cString: curseur.pointee.ifa_name)
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (ifaFlags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                // if (ifaFlags & (IFF_UP|IFF_RUNNING)) == (IFF_UP|IFF_RUNNING) {
                switch Int32(ifaAddr.pointee.sa_family) {
                    case AF_LINK:
                        // "Get MAC address" depuis la structure sockaddr_dl et charger le dicNameToMac
                        ifaAddr.withMemoryRebound(to: sockaddr_dl.self, capacity: 1)
                        { dl in dl.withMemoryRebound(to: Int8.self, capacity: 8 + Int(dl.pointee.sdl_nlen + dl.pointee.sdl_alen))
                        {let lladdr = UnsafeBufferPointer(start: $0 + 8 + Int(dl.pointee.sdl_nlen),
                                                          count: Int(dl.pointee.sdl_alen))
                            if lladdr.count == 6 {
                                dicNameToMac[ifaName] = lladdr.map { String(format:"%02hhx", $0)}.joined(separator:":")
                                if (!bIpv4.isOn && !bIpv6.isOn) {print(dicNameToMac[ifaName] ?? "-> " , ifaName) }
                            }
                        }}
                    case AF_INET :
//                    case AF_INET, AF_INET6:
                        if bIpv4.isOn {
                        var adrIpChar = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(ifaAddr, socklen_t(ifaAddr.pointee.sa_len), &adrIpChar,
                                        socklen_t(adrIpChar.count), nil,
                                        socklen_t(0),NI_NUMERICHOST) == 0)
                        {
                            // Convertir l'addresse de l'interface en une chaine lisible :
                            let adrIp = String(cString: adrIpChar)
                            // print("adrIpChar -> adrIp : \(adrIp)")
                            tabNic.append( (name: ifaName, addr: adrIp, mac : "") )
                        }}
                    case AF_INET6: // identique au cas IPv4
                        if bIpv6.isOn {
                        var adrIpChar = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(ifaAddr, socklen_t(ifaAddr.pointee.sa_len), &adrIpChar,
                                        socklen_t(adrIpChar.count), nil,
                                        socklen_t(0),NI_NUMERICHOST) == 0)
                        {
                            // Convertir l'addresse de l'interface en une chaine lisible :
                            let adrIp = String(cString: adrIpChar)
                            // print("adrIpChar -> adrIp : \(adrIp)")
                            tabNic.append( (name: ifaName, addr: adrIp, mac : "") )
                        }}
                    default:
                        print("improbable ?")
                        break
                }
            }
        }
    }
    // Les données renvoyées par getifaddrs () sont allouées dynamiquement
    //  et doivent être libérées à l'aide de freeifaddrs () lorsqu'elles ne sont plus nécessaires.
    freeifaddrs(listeAdr)
    // Remplissage des address MAC dans les tuples du Tableau
    for (i, ifaAdr) in tabNic.enumerated() {
        if let mac = dicNameToMac[ifaAdr.name] {
            tabNic[i] = (name: ifaAdr.name, addr: ifaAdr.addr, mac : mac)
            // print("name: \(ifaAdr.name), addr: \(ifaAdr.addr), mac : \(mac)")
        }
    }
    return tabNic
}
