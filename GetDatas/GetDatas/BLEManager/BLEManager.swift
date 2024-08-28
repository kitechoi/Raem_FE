//
//  BLEManager.swift
//  GetDatas
//
//  Created by 정현조 on 8/25/24.
//
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let connectSuccessNotification = Notification.Name("connectSuccessNotification")
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    private var connectedPeripheral: CBPeripheral?
    //@Published var hasKnownRaem: Bool = false //원래 아는 기기인지
    @Published var connectSuccess: Bool?
    
    //LED 제어
    private var LEDService: CBService?
    private var LEDCharacteristic: CBCharacteristic?
    private var LEDServiceUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614174000")
    private var LEDCharacteristicUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614174001")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func connectDevice() {
        if let peripheral = discoveredPeripheral {
            centralManager.connect(peripheral, options: nil)
        } else {
            print("No peripheral to connect")
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
//            if !hasKnownRaem {
//                startScanning()
//            }
            startScanning()
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name ?? "Unknown"
        
//        if deviceName.contains("정현조") {
//            discoveredPeripheral = peripheral
//            discoveredPeripheral?.delegate = self
//        }
        
        if deviceName == "Raem" {
            discoveredPeripheral = peripheral
            discoveredPeripheral?.delegate = self
        }
    }
    
    // 기기와 연결되었을 때 호출됩니다.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        
        // Stop scanning
        centralManager.stopScan()
        print("Scanning stopped")
        
        // Save UUID for after
//        let uuid = peripheral.identifier.uuidString
//        UserDefaults.standard.set(uuid, forKey: "SavedDeviceUUID")
        
        peripheral.discoverServices(nil)
        connectedPeripheral = peripheral
        connectSuccess = true
    }
    
    // 기기와 연결 실패했을 때 호출됩니다.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown Device")")
        connectSuccess = false
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                print("Discovered service: \(service)")
                            
                // 원하는 서비스 UUID를 확인하고 특성을 검색
                if service.uuid == LEDServiceUUID {
                    LEDService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == LEDCharacteristicUUID {
                    LEDCharacteristic = characteristic
//                    if characteristic.properties.contains(.write){
//                        let data = "25.5,25.5,25.5".data(using: .utf8)!
//                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
//                    }
                }
            }
        }
    }
    
    func disconnect(){
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
//    func retrieveKnownPeripherals() {
//        // 저장된 UUID 가져오기
//        if let savedUUIDString = UserDefaults.standard.string(forKey: "SavedDeviceUUID"),
//           let uuid = UUID(uuidString: savedUUIDString) {
//            //스캔 멈추기
//            centralManager.stopScan()
//            print("Scanning stopped")
//            
//            // 저장된 UUID를 사용하여 기기 검색
//            let knownPeripherals = centralManager.retrievePeripherals(withIdentifiers: [uuid])
//            
//            // 재연결
//            for peripheral in knownPeripherals {
//                print("Previously connected device: \(peripheral.name ?? "Unknown")")
//                centralManager.connect(peripheral, options: nil)
//            }
//            
//            hasKnownRaem = true
//        } else {
//            print("No previously saved device UUID found.")
//        }
//    }
    
    func controllLED(_ data: String){
        if let peripheral = discoveredPeripheral, let characteristic = LEDCharacteristic {
            peripheral.writeValue(data.data(using: .utf8)!, for: characteristic, type: .withResponse)
        } else {
            print("No connected peripheral or characteristic found")
        }
    }
}
