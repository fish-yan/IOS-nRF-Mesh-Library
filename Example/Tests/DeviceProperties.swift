/*
* Copyright (c) 2021, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import XCTest
@testable import nRFMeshProvision

class DeviceProperties: XCTestCase {

    func testPercentage8() throws {
        let samples: [(Data, Decimal?, Data)] = [
            (Data([0]),   0.0,   Data([0])),         // min
            (Data([1]),   0.5,   Data([1])),        // basic
            (Data([100]), 50.0,  Data([100])),     // middle
            (Data([200]), 100.0, Data([200])),    // max
            (Data([201]), 100.0, Data([200])),   // trundated
            (Data([0xFF]), nil,  Data([0xFF])), // unknown
        ]
        
        for (sample, result, encoded) in samples {
            let characteristic = DeviceProperty.motionSensed.read(from: sample, at: 0, length: 1)
            switch characteristic {
            case .percentage8(let percent):
                XCTAssertEqual(percent, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
            default:
                XCTFail("Failed to parse \(sample.hex) into .percentage8")
            }
            
            let test = DevicePropertyCharacteristic.percentage8(result)
            XCTAssertEqual(test, characteristic)
            XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
        }
    }
    
    func testTooHighPercentage8() throws {
        let characteristic = DevicePropertyCharacteristic.percentage8(123.456)
        // This test may fail if a non-US Locale is set.
        XCTAssertEqual(characteristic.debugDescription, "100,0%")
        XCTAssertEqual(characteristic.data, Data([0xC8]), "\(characteristic.data.hex) != 0xC8")
    }
    
    func testTooLowPercentage8() throws {
        let characteristic = DevicePropertyCharacteristic.percentage8(-123.456)
        // This test may fail if a non-US Locale is set.
        // This test may fail if a non-US Locale is set.
        XCTAssertEqual(characteristic.debugDescription, "0,0%")
        XCTAssertEqual(characteristic.data, Data([0x00]), "\(characteristic.data.hex) != 0x00")
    }
    
    func testTemperature8() throws {
        let samples: [(Data, Decimal?, Data)] = [
            (Data([0x80]), -64.0, Data([0x80])),     // min
            (Data([0]),    0.0,   Data([0])),       // basic
            (Data([1]),    0.5,   Data([1])),      // middle
            (Data([126]),  63.0,  Data([126])),   // max
            (Data([0x7F]), nil,   Data([0x7F])), // unknown
        ]
        
        for (sample, result, encoded) in samples {
            let characteristic = DeviceProperty.desiredAmbientTemperature.read(from: sample, at: 0, length: 1)
            switch characteristic {
            case .temperature8(let temp):
                XCTAssertEqual(temp, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
            default:
                XCTFail("Failed to parse \(sample.hex) into .temperature8")
            }
            
            let test = DevicePropertyCharacteristic.temperature8(result)
            XCTAssertEqual(test, characteristic)
            XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
        }
    }
    
    func testPerceivedLightness() throws {
        let samples: [(Data, UInt16, Data)] = [
            (Data([0x00, 0x00]), 0x0000, Data([0x00, 0x00])),    // min
            (Data([0x01, 0x00]), 0x0001, Data([0x01, 0x00])),   // basic
            (Data([0xCD, 0xAB]), 0xABCD, Data([0xCD, 0xAB])),  // middle
            (Data([0xFF, 0xFF]), 0xFFFF, Data([0xFF, 0xFF])), // max
        ]
        
        for (sample, result, encoded) in samples {
            let characteristic = DeviceProperty.lightControlLightnessOn.read(from: sample, at: 0, length: 2)
            switch characteristic {
            case .perceivedLightness(let value):
                XCTAssertEqual(value, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
            default:
                XCTFail("Failed to parse \(sample.hex) into .perceivedLightness")
            }
            
            let test = DevicePropertyCharacteristic.perceivedLightness(result)
            XCTAssertEqual(test, characteristic)
            XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
        }
    }
    
    func testCount16() throws {
        let samples: [(Data, UInt16?, Data)] = [
            (Data([0x00, 0x00]), 0x0000, Data([0x00, 0x00])),     // min
            (Data([0x01, 0x00]), 0x0001, Data([0x01, 0x00])),    // basic
            (Data([0xCD, 0xAB]), 0xABCD, Data([0xCD, 0xAB])),   // middle
            (Data([0xFE, 0xFF]), 0xFFFE, Data([0xFE, 0xFF])),  // max
            (Data([0xFF, 0xFF]), nil,    Data([0xFF, 0xFF])), // unknown
        ]
        
        for (sample, result, encoded) in samples {
            let characteristic = DeviceProperty.peopleCount.read(from: sample, at: 0, length: 2)
            switch characteristic {
            case .count16(let count):
                XCTAssertEqual(count, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
            default:
                XCTFail("Failed to parse \(sample.hex) into .count16")
            }
            
            let test = DevicePropertyCharacteristic.count16(result)
            XCTAssertEqual(test, characteristic)
            XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
        }
    }
    
    func testHumidity() throws {
        let samples: [(Data, Decimal?, Data)] = [
            (Data([0x00, 0x00]), 0.0,   Data([0x00, 0x00])),      // min
            (Data([0x01, 0x00]), 0.01,  Data([0x01, 0x00])),     // basic
            (Data([0xD2, 0x04]), 12.34, Data([0xD2, 0x04])),    // middle
            (Data([0x10, 0x27]), 100.0, Data([0x10, 0x27])),   // max
            (Data([0x11, 0x27]), 100.0, Data([0x10, 0x27])),  // trucated
            (Data([0xFF, 0xFF]), nil,   Data([0xFF, 0xFF])), // unknown
        ]
        
        for (sample, result, encoded) in samples {
            let characteristic = DeviceProperty.presentIndoorRelativeHumidity.read(from: sample, at: 0, length: 2)
            switch characteristic {
            case .humidity(let percent):
                XCTAssertEqual(percent, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
            default:
                XCTFail("Failed to parse \(sample.hex) into .humidity")
            }
            
            let test = DevicePropertyCharacteristic.humidity(result)
            XCTAssertEqual(test, characteristic)
            XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
        }
    }
    
    func testTemperature() throws {
        let samples: [(Data, Decimal?, Data)] = [
            (Data([0x4D, 0x95]), Decimal(string: "-273.15"), Data([0x4D, 0x95])),      // min
            (Data([0x01, 0x00]), Decimal(string:    "0.01"), Data([0x01, 0x00])),     // basic
            (Data([0xD2, 0x04]), Decimal(string:   "12.34"), Data([0xD2, 0x04])),    // middle
            (Data([0xFF, 0x7F]), Decimal(string:  "327.67"), Data([0xFF, 0x7F])),   // max
            (Data([0xD0, 0x8A]), Decimal(string: "-273.15"), Data([0x4D, 0x95])),  // trucated
            (Data([0x00, 0x80]), nil,                        Data([0x00, 0x80])), // unknown
        ]
        
        for (sample, result, encoded) in samples {
            let characteristic = DeviceProperty.precisePresentAmbientTemperature.read(from: sample, at: 0, length: 2)
            switch characteristic {
            case .temperature(let temp):
                XCTAssertEqual(temp, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
            default:
                XCTFail("Failed to parse \(sample.hex) into .temperature")
            }
            
            let test = DevicePropertyCharacteristic.temperature(result)
            XCTAssertEqual(test, characteristic)
            XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
        }
    }
    
    func testPressure() throws {
        // Presure values are in Pascals. Data is encoded in hPa.
        let samples: [(Data, Decimal, Data)] = [
            (Data([0x00, 0x00, 0x00, 0x00]), Decimal(string:         "0.0" /* Pa */)!, Data([0x00, 0x00, 0x00, 0x00])),     // zero
            (Data([0x01, 0x00, 0x00, 0x00]), Decimal(string:         "0.1" /* Pa */)!, Data([0x01, 0x00, 0x00, 0x00])),    // min
            (Data([0x0A, 0x00, 0x00, 0x00]), Decimal(string:         "1.0" /* Pa */)!, Data([0x0A, 0x00, 0x00, 0x00])),   // basic
            (Data([0xD2, 0x04, 0x00, 0x00]), Decimal(string:       "123.4" /* Pa */)!, Data([0xD2, 0x04, 0x00, 0x00])),  // middle
            (Data([0xFF, 0xFF, 0xFF, 0xFF]), Decimal(string: "429496729.5" /* Pa */)!, Data([0xFF, 0xFF, 0xFF, 0xFF])), // max
        ]
        
        for (sample, result, encoded) in samples {
            let characteristic = DeviceProperty.pressure.read(from: sample, at: 0, length: 4)
            switch characteristic {
            case .pressure(let pressure):
                XCTAssertEqual(pressure, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
            default:
                XCTFail("Failed to parse \(sample.hex) into .pressure")
            }
            
            let test = DevicePropertyCharacteristic.pressure(result)
            XCTAssertEqual(test, characteristic)
            XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
        }
    }
    
    func testCoefficient() throws {
        let samples: [(Data, Float, Data)] = [
            (Data([0xA4, 0x70, 0x45, 0x41]), 12.34,      Data([0xA4, 0x70, 0x45, 0x41])),       // basic
            (Data([0x17, 0xB7, 0xD1, 0xB8]), -0.0001,    Data([0x17, 0xB7, 0xD1, 0xB8])),      // negative
            (Data([0x00, 0x00, 0x00, 0x00]),  0.00,      Data([0x00, 0x00, 0x00, 0x00])),     // zero
            (Data([0x00, 0x00, 0x00, 0x80]), -.zero,     Data([0x00, 0x00, 0x00, 0x80])),    // negative zero
            (Data([0x00, 0x00, 0x80, 0x7F]),  .infinity, Data([0x00, 0x00, 0x80, 0x7F])),   // positive infinity
            (Data([0x00, 0x00, 0x80, 0xFF]), -.infinity, Data([0x00, 0x00, 0x80, 0xFF])),  // negative infinity
            (Data([0xFF, 0xFF, 0xFF, 0x7F]),  .nan,      Data([0xFF, 0xFF, 0xFF, 0x7F])), // NaN
        ]
        
        for (sample, result, encoded) in samples {
            let characteristic = DeviceProperty.sensorGain.read(from: sample, at: 0, length: 4)
            switch characteristic {
            case .coefficient(let value):
                if value.isNaN {
                    XCTAssertTrue(result.isNaN, "Result is not NaN")
                } else {
                    XCTAssertEqual(value, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
                }
            default:
                XCTFail("Failed to parse \(sample.hex) into .coefficient")
            }
            
            let test = DevicePropertyCharacteristic.coefficient(result)
            if result.isNaN, case .coefficient(let value) = test {
                XCTAssert(value.isNaN)
            } else {
                XCTAssertEqual(test, characteristic)
            }
            XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
        }
    }
    
    func testDateUTC() throws {
        let dayInSeconds: TimeInterval = 86400.0
        let samples: [(Data, Date?, Data)] = [
            (Data([0x01, 0x00, 0x00]), Date(timeIntervalSince1970: 0x000001 * dayInSeconds), Data([0x01, 0x00, 0x00])),     // min
            (Data([0x0F, 0x00, 0x00]), Date(timeIntervalSince1970: 0x00000F * dayInSeconds), Data([0x0F, 0x00, 0x00])),    // basic
            (Data([0x56, 0x34, 0x12]), Date(timeIntervalSince1970: 0x123456 * dayInSeconds), Data([0x56, 0x34, 0x12])),   // middle
            (Data([0xFF, 0xFF, 0xFF]), Date(timeIntervalSince1970: 0xFFFFFF * dayInSeconds), Data([0xFF, 0xFF, 0xFF])),  // max
            (Data([0x00, 0x00, 0x00]), nil,                                                  Data([0x00, 0x00, 0x00])), // unknown
        ]
        
        for (sample, result, encoded) in samples {
            let characteristic = DeviceProperty.deviceDateOfManufacture.read(from: sample, at: 0, length: 3)
            switch characteristic {
            case .dateUTC(let date):
                XCTAssertEqual(date, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
            default:
                XCTFail("Failed to parse \(sample.hex) into .dateUTC")
            }
            
            let test = DevicePropertyCharacteristic.dateUTC(result)
            XCTAssertEqual(test, characteristic)
            XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
        }
    }

    func testElectricCurrent() throws {
        let samples: [(Data, Decimal?, Data)] = [
            (Data([0x00, 0x00]), Decimal(string:      "0"), Data([0x00, 0x00])), // min
            (Data([0x01, 0x00]), Decimal(string:   "0.01"), Data([0x01, 0x00])), // basic
            (Data([0xFF, 0x7F]), Decimal(string: "327.67"), Data([0xFF, 0x7F])), // middle
            (Data([0xFE, 0xFF]), Decimal(string: "655.34"), Data([0xFE, 0xFF])), // max
            (Data([0xFF, 0xFF]), nil,                       Data([0xFF, 0xFF])), // unknown
        ]
        
        let deviceProperties: [DeviceProperty] = [
            .presentOutputCurrent,
            .presentInputCurrent,
        ]

        for (sample, result, encoded) in samples {
            for deviceProperty in deviceProperties {
                let characteristic = deviceProperty.read(from: sample, at: 0, length: 2)
                switch characteristic {
                case .electricCurrent(let current):
                    XCTAssertEqual(current, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
                default:
                    XCTFail("Failed to parse \(deviceProperty) \(sample.hex) into .electricCurrent")
                }
                
                let test = DevicePropertyCharacteristic.electricCurrent(result)
                XCTAssertEqual(test, characteristic)
                XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
            }
        }
    }
    
    func testPower() throws {
        let samples: [(Data, Decimal?, Data)] = [
            (Data([0x00, 0x00, 0x00]), Decimal(string:         "0"), Data([0x00, 0x00, 0x00])), // min
            (Data([0x01, 0x00, 0x00]), Decimal(string:       "0.1"), Data([0x01, 0x00, 0x00])), // basic
            (Data([0xFF, 0xFF, 0x7F]), Decimal(string: " 838860.7"), Data([0xFF, 0xFF, 0x7F])), // middle
            (Data([0xFE, 0xFF, 0xFF]), Decimal(string: "1677721.4"), Data([0xFE, 0xFF, 0xFF])), // max
            (Data([0xFF, 0xFF, 0xFF]), nil,                          Data([0xFF, 0xFF, 0xFF])), // unknown
        ]
        
        let deviceProperties: [DeviceProperty] = [
            .activePowerLoadside,
            .luminaireNominalInputPower,
            .luminairePowerAtMinimumDimLevel,
            .presentDeviceInputPower
        ]
        
        for (sample, result, encoded) in samples {
            for deviceProperty in deviceProperties {
                let characteristic = deviceProperty.read(from: sample, at: 0, length: 3)
                switch characteristic {
                case .power(let power):
                    XCTAssertEqual(power, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
                default:
                    XCTFail("Failed to parse \(deviceProperty) \(sample.hex) into .power")
                }
                
                let test = DevicePropertyCharacteristic.power(result)
                XCTAssertEqual(test, characteristic)
                XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
            }
        }
    }
    
    func testEnergy32() throws {
        let samples: [(Data, ValidDecimal?, Data)] = [
            (Data([0x00, 0x00, 0x00, 0x00]), .valid(Decimal(string: "          0")!), Data([0x00, 0x00, 0x00, 0x00])), // min
            (Data([0x01, 0x00, 0x00, 0x00]), .valid(Decimal(string: "      0.001")!), Data([0x01, 0x00, 0x00, 0x00])), // basic
            (Data([0xFE, 0xFF, 0xFF, 0x7F]), .valid(Decimal(string: "2147483.646")!), Data([0xFE, 0xFF, 0xFF, 0x7F])), // middle
            (Data([0xFD, 0xFF, 0xFF, 0xFF]), .valid(Decimal(string: "4294967.293")!), Data([0xFD, 0xFF, 0xFF, 0xFF])), // max
            (Data([0xFE, 0xFF, 0xFF, 0xFF]), .invalid                               , Data([0xFE, 0xFF, 0xFF, 0xFF])), // not valid
            (Data([0xFF, 0xFF, 0xFF, 0xFF]), nil                                    , Data([0xFF, 0xFF, 0xFF, 0xFF])), // unknown
        ]
        
        let deviceProperties: [DeviceProperty] = [
            .preciseTotalDeviceEnergyUse,
            .activeEnergyLoadside
        ]
        
        for (sample, result, encoded) in samples {
            for deviceProperty in deviceProperties {
                let characteristic = deviceProperty.read(from: sample, at: 0, length: 4)
                switch characteristic {
                case .energy32(let energy):
                    XCTAssertEqual(energy, result, "Failed to parse \(sample.hex) into \(String(describing: result))")
                default:
                    XCTFail("Failed to parse \(deviceProperty) \(sample.hex) into .energy32")
                }
                let test = DevicePropertyCharacteristic.energy32(result)
                XCTAssertEqual(test, characteristic)
                XCTAssertEqual(characteristic.data, encoded, "\(characteristic.data.hex) != \(encoded.hex)")
            }
        }
    }

}
