//
//  File.swift
//  VPN
//
//  Created by Ruslan on 26.01.23.
//

import Foundation
import NetworkExtension

final class VPNHandler {

    let vpnManager = NEVPNManager.shared()
    

    func initVPNTunnelProviderManager() {

        print("CALL LOAD TO PREFERENCES...")
        self.vpnManager.loadFromPreferences { (error) -> Void in

            if((error) != nil) {

                print("VPN Preferences error: 1")
            } else {

                let IKEv2Protocol = NEVPNProtocolIKEv2()
                
                IKEv2Protocol.username = "user"
                IKEv2Protocol.passwordReference = "password".data(using: .utf8)?.base64EncodedData()
                IKEv2Protocol.serverAddress = ""
                
//                IKEv2Protocol.username = vpnUser.username
//                IKEv2Protocol.serverAddress = vpnServer.serverID //server tunneling Address
//                IKEv2Protocol.remoteIdentifier = vpnServer.remoteID //Remote id
//                IKEv2Protocol.localIdentifier = vpnUser.localID //Local id
                

                IKEv2Protocol.deadPeerDetectionRate = .low
                IKEv2Protocol.authenticationMethod = .none
                IKEv2Protocol.useExtendedAuthentication = true //if you are using sharedSecret method then make it false
                IKEv2Protocol.disconnectOnSleep = false

                //Set IKE SA (Security Association) Params...
                IKEv2Protocol.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
                IKEv2Protocol.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA256
                IKEv2Protocol.ikeSecurityAssociationParameters.diffieHellmanGroup = .group14
                IKEv2Protocol.ikeSecurityAssociationParameters.lifetimeMinutes = 1440
                //IKEv2Protocol.ikeSecurityAssociationParameters.isProxy() = false

                //Set CHILD SA (Security Association) Params...
                IKEv2Protocol.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
                IKEv2Protocol.childSecurityAssociationParameters.integrityAlgorithm = .SHA256
                IKEv2Protocol.childSecurityAssociationParameters.diffieHellmanGroup = .group14
                IKEv2Protocol.childSecurityAssociationParameters.lifetimeMinutes = 1440

                let kcs = KeychainService()
                //Save password in keychain...
//                kcs.save(key: "VPN_PASSWORD", value: vpnUser.password)
                //Load password from keychain...
                IKEv2Protocol.passwordReference = kcs.load(key: "VPN_PASSWORD")

                self.vpnManager.protocolConfiguration = IKEv2Protocol
                self.vpnManager.localizedDescription = "Safe Login Configuration"
                self.vpnManager.isEnabled = true

                self.vpnManager.isOnDemandEnabled = true
                //print(IKEv2Protocol)

                //Set rules
                var rules = [NEOnDemandRule]()
                let rule = NEOnDemandRuleConnect()
                rule.interfaceTypeMatch = .any
                rules.append(rule)

                print("SAVE TO PREFERENCES...")
                //SAVE TO PREFERENCES...
                self.vpnManager.saveToPreferences(completionHandler: { (error) -> Void in
                    if((error) != nil) {

                        print("VPN Preferences error: 2")
                    } else {

                        print("CALL LOAD TO PREFERENCES AGAIN...")
                        //CALL LOAD TO PREFERENCES AGAIN...
                        self.vpnManager.loadFromPreferences(completionHandler: { (error) in
                            if ((error) != nil) {
                                print("VPN Preferences error: 2")
                            } else {
                                var startError: NSError?
                                do {
                                    //START THE CONNECTION...
                                    try self.vpnManager.connection.startVPNTunnel()
                                } catch let error as NSError {

                                    startError = error
                                    print(startError.debugDescription)
                                } catch {

                                    print("Fatal Error")
                                    fatalError()
                                }
                                if ((startError) != nil) {
                                    print("VPN Preferences error: 3")

                                    //Show alert here
                                    print("title: Oops.., message: Something went wrong while connecting to the VPN. Please try again.")

                                    print(startError.debugDescription)
                                } else {
                                    //self.VPNStatusDidChange(nil)
                                    print("Starting VPN...")
                                }
                            }
                        })
                    }
                })
            }
        } //END OF .loadFromPreferences //

    }

    //MARK:- Connect VPN
    static func connectVPN() {
        VPNHandler().initVPNTunnelProviderManager()
    }

    //MARK:- Disconnect VPN
    static func disconnectVPN() {
        VPNHandler().vpnManager.connection.stopVPNTunnel()
    }

    //MARK:- check connection staatus
    static func checkStatus() {

        let status = VPNHandler().vpnManager.connection.status
        print("VPN connection status = \(status.rawValue)")

        switch status {
        case NEVPNStatus.connected:

            print("Connected")

        case NEVPNStatus.invalid, NEVPNStatus.disconnected :

            print("Disconnected")

        case NEVPNStatus.connecting , NEVPNStatus.reasserting:

            print("Connecting")

        case NEVPNStatus.disconnecting:

            print("Disconnecting")

        default:
            print("Unknown VPN connection status")
        }
    }
}


class ServerList: ObservableObject {
    @Published var servers: [Server]
    
    init() {
        // initialize the server list, this can be done by fetching them from a remote server or a local storage
        self.servers = [Server(name: "Server 1", protocolConfiguration: NEVPNProtocolIKEv2()),
                        Server(name: "Server 2", protocolConfiguration: NEVPNProtocolIKEv2()),
                        Server(name: "Server 3", protocolConfiguration: NEVPNProtocolIKEv2())]
    }
}



struct Server {
    var name: String
    var protocolConfiguration: NEVPNProtocol
}
