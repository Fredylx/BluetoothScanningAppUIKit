//
//  ViewController.swift
//  BluetoothScanningAppUIKit
//
//  Created by Fredy lopez on 10/16/23.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    private var centralManager: CBCentralManager!
    private var currentPeripheral: CBPeripheral!
    var peripheral: CBPeripheral!
    var devicesList:[CBPeripheral] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }


}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devicesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        let peripheral = devicesList[indexPath.row]
        cell.textLabel?.text = peripheral.name ?? "Unknown Device"
        cell.detailTextLabel?.text = peripheral.identifier.uuidString ?? "Unknown UUID"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = devicesList[indexPath.row]
        print("peripheral Identifier \(peripheral.identifier)")
        print("peripheral Name \(peripheral.name ?? "Unknown Device")")
        print("peripheral Description \(peripheral.description)")
        print("peripheral State \(peripheral.state)")
        print("peripheral Services \(peripheral.services ?? [])")
        print("peripheral WriteWithoutResponse \(peripheral.canSendWriteWithoutResponse)")
        print("peripheral RespondsToUserInteraction \(peripheral.accessibilityRespondsToUserInteraction)")
        
        self.centralManager.stopScan()
        currentPeripheral = peripheral
        currentPeripheral.delegate = self
        centralManager.connect(currentPeripheral, options: nil)
        
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager State Update")
        
        if centralManager.state != .poweredOn{
            print("Bluetooth is off for current Device")
            
        } else {
            print("Bluetooth is On")
            centralManager.scanForPeripherals(withServices: nil)
            
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if !devicesList.contains(peripheral){
            devicesList.append(peripheral)
            tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: Error?) {
        print("Disconnected")
    }
}

extension ViewController: CBPeripheralDelegate {
    
    //handling discovery related info
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(" Name \(peripheral.name ?? "Unknown Device")")
        print(" state \(peripheral.state.rawValue)")
        print(" service \(peripheral.services ?? [])")
        
        
        if let services = peripheral.services{
            for service in services{
                print("service found")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        print("didDiscoverServices -\(peripheral.services)")
        print("error -\(error?.localizedDescription)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("service found")
                peripheral.discoverCharacteristics([CBUUID(string: peripheral.identifier.uuidString)], for: service)
            }
        }
        
        print(characteristic.value?.first ?? "No characteristic first value")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print(" notify -\(characteristic.uuid)")
        print(" notify -\(characteristic.isNotifying)")
        print(" notify -\(characteristic.service?.description)")
        
        print("Error - \(error?.localizedDescription)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.currentPeripheral{
            print("connected to particular bluetooth device")
            peripheral.discoverServices([CBUUID(string: peripheral.identifier.uuidString)])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
    }
}
    
