//
//  File.swift
//  VPN
//
//  Created by Ruslan on 26.01.23.
//

import Foundation
import NetworkExtension



final class VPNHandler {

    private let vpnManager = NEVPNManager.shared()
    static let shared = VPNHandler()
    

    func initVPNTunnelProviderManager() {

        print("CALL LOAD TO PREFERENCES...")
        self.vpnManager.loadFromPreferences { (error) -> Void in

            if((error) != nil) {

                print("VPN Preferences error: 1")
            } else {

                let vpnProtocol = NEVPNProtocolIKEv2()
                
                vpnProtocol.username = "user"
                vpnProtocol.passwordReference = "password".data(using: .utf8)?.base64EncodedData()
                vpnProtocol.serverAddress = ""
                
//                IKEv2Protocol.username = vpnUser.username
//                IKEv2Protocol.serverAddress = vpnServer.serverID //server tunneling Address
//                IKEv2Protocol.remoteIdentifier = vpnServer.remoteID //Remote id
//                IKEv2Protocol.localIdentifier = vpnUser.localID //Local id
                

                vpnProtocol.deadPeerDetectionRate = .low
                vpnProtocol.authenticationMethod = .none
                vpnProtocol.useExtendedAuthentication = true //if you are using sharedSecret method then make it false
                vpnProtocol.disconnectOnSleep = false

                //Set IKE SA (Security Association) Params...
                vpnProtocol.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
                vpnProtocol.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA256
                vpnProtocol.ikeSecurityAssociationParameters.diffieHellmanGroup = .group14
                vpnProtocol.ikeSecurityAssociationParameters.lifetimeMinutes = 1440
                //IKEv2Protocol.ikeSecurityAssociationParameters.isProxy() = false

                //Set CHILD SA (Security Association) Params...
                vpnProtocol.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
                vpnProtocol.childSecurityAssociationParameters.integrityAlgorithm = .SHA256
                vpnProtocol.childSecurityAssociationParameters.diffieHellmanGroup = .group14
                vpnProtocol.childSecurityAssociationParameters.lifetimeMinutes = 1440

                let kcs = KeychainService()
                //Save password in keychain...
//                kcs.save(key: "VPN_PASSWORD", value: vpnUser.password)
                //Load password from keychain...
                vpnProtocol.passwordReference = kcs.load(key: "VPN_PASSWORD")

                self.vpnManager.protocolConfiguration = vpnProtocol
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
               try? self.vpnManager.connection.startVPNTunnel()
            }
        } //END OF .loadFromPreferences //

    }

    //MARK:- Connect VPN
     func connectVPN() {
        VPNHandler().initVPNTunnelProviderManager()
    }

    //MARK:- Disconnect VPN
     func disconnectVPN() {
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
