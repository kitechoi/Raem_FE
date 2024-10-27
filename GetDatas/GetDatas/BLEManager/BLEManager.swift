import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let connectSuccessNotification = Notification.Name("connectSuccessNotification")
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    private var connectedPeripheral: CBPeripheral?
    @Published var connectSuccess: Bool = false
    
    // LED 제어
    private var LEDService: CBService?
    private var LEDCharacteristic: CBCharacteristic?
    private var LEDServiceUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614174000")
    private var LEDCharacteristicUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614174001")
    
    // Audio 제어
    private var AudioService: CBService?
    private var AudioOnCharacteristic: CBCharacteristic?
    private var ChangeVolumeCharacteristic: CBCharacteristic?
    private var AudioOffCharacteristic: CBCharacteristic?
    private var AudioServiceUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614175000")
    private var AudioOnCharacteristicUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614175001")
    private var ChangeVolumeCharacteristicUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614175002")
    private var AudioOffCharacteristicUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614175003")
    
    // Alarm 제어
    private var AlarmService: CBService?
    private var AlarmOnCharacteristic: CBCharacteristic?
    private var AlarmOffCharacteristic: CBCharacteristic?
    private var AlarmServiceUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614176000")
    private var AlarmOnCharacteristicUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614176001")
    private var AlarmOffCharacteristicUUID: CBUUID = CBUUID(string: "123e4567-e89b-12d3-a456-426614176002")
    
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
            connectSuccess = true
        } else {
            print("No peripheral to connect")
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name ?? "Unknown"
        
        if deviceName == "Raem" {
            discoveredPeripheral = peripheral
            discoveredPeripheral?.delegate = self
            // 연결 시도는 connectDevice() 메서드를 호출할 때만 진행하도록 수정됨
            // centralManager.connect(peripheral, options: nil) // 이 부분은 제거됨
        }
    }
    
    // 기기와 연결되었을 때 호출됩니다.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        
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
                if service.uuid == LEDServiceUUID {
                    LEDService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                } else if service.uuid == AudioServiceUUID {
                    AudioService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                } else if service.uuid == AlarmServiceUUID {
                    AlarmService = service
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
                print(characteristic)
                if characteristic.uuid == LEDCharacteristicUUID {
                    LEDCharacteristic = characteristic
                } else if characteristic.uuid == AudioOnCharacteristicUUID {
                    AudioOnCharacteristic = characteristic
                } else if characteristic.uuid == ChangeVolumeCharacteristicUUID {
                    ChangeVolumeCharacteristic = characteristic
                } else if characteristic.uuid == AudioOffCharacteristicUUID {
                    AudioOffCharacteristic = characteristic
                } else if characteristic.uuid == AlarmOnCharacteristicUUID {
                    AlarmOnCharacteristic = characteristic
                } else if characteristic.uuid == AlarmOffCharacteristicUUID {
                    AlarmOffCharacteristic = characteristic
                }
            }
        }
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectSuccess = false
            print("Successfully Disconnect")
        }
    }
    
    func controllLED(_ data: String) {
        if let peripheral = discoveredPeripheral, let characteristic = LEDCharacteristic {
            peripheral.writeValue(data.data(using: .utf8)!, for: characteristic, type: .withResponse)
        } else {
            print("No connected peripheral or characteristic found")
        }
    }
    
    func turnOnAudio(_ data: String) {
        if let peripheral = discoveredPeripheral, let characteristic = AudioOnCharacteristic {
            peripheral.writeValue(data.data(using: .utf8)!, for: characteristic, type: .withResponse)
        } else {
            print("No connected peripheral or audio on characteristic found")
        }
    }

    func setVolume(_ volume: Int) {
        if let peripheral = discoveredPeripheral, let characteristic = ChangeVolumeCharacteristic {
            peripheral.writeValue(String(volume).data(using: .utf8)!, for: characteristic, type: .withResponse)
        } else {
            print("No connected peripheral or volume characteristic found")
        }
    }

    func turnOffAudio(_ data: String) {
        if let peripheral = discoveredPeripheral, let characteristic = AudioOffCharacteristic {
            print(data)
            peripheral.writeValue(data.data(using: .utf8)!, for: characteristic, type: .withResponse)
        } else {
            print("No connected peripheral or audio off characteristic found")
        }
    }
    
    func turnOnAlarm(_ data: String) {
        if let peripheral = discoveredPeripheral, let characteristic = AlarmOnCharacteristic {
            peripheral.writeValue(data.data(using: .utf8)!, for: characteristic, type: .withResponse)
        } else {
            print("No connected peripheral or alarm on characteristic found")
        }
    }
    
    func turnOffAlarm(_ data: String) {
        if let peripheral = discoveredPeripheral, let characteristic = AlarmOffCharacteristic {
            peripheral.writeValue(data.data(using: .utf8)!, for: characteristic, type: .withResponse)
        } else {
            print("No connected peripheral or alarm off characteristic found")
        }
    }
}
