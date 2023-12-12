import Foundation
import Capacitor
import HealthKit

var healthStore = HKHealthStore()

struct NormalizedQuantity {
    var unit: HKUnit?
    var unitName: String
    var value: Double
    
    init(quantityType: String, quantity: HKQuantity) {
        if quantityType == "heartRate" {
            self.unit = HKUnit(from: "count/min")
            self.unitName = "BPM"
        } else if quantityType == "oxygenSaturation" {
            self.unit = HKUnit.percent()
            self.unitName = "%"
        } else if quantityType == "weight" {
            self.unit = HKUnit.pound()
            self.unitName = "pound"
        } else if quantity.is(compatibleWith: HKUnit.inch()) {
            self.unit = HKUnit.inch()
            self.unitName = "inch"
        } else if quantity.is(compatibleWith: HKUnit.count()) {
            self.unit = HKUnit.count()
            self.unitName = "count"
        } else if quantity.is(compatibleWith: HKUnit.minute()) {
            self.unit = HKUnit.minute()
            self.unitName = "minute"
        } else if quantity.is(compatibleWith: HKUnit.kilocalorie()) {
            self.unit = HKUnit.kilocalorie()
            self.unitName = "kilocalorie"
        } else {
            self.unitName = ""
            self.value = 0

            return
        }
        
        self.value = quantity.doubleValue(for: self.unit!)
    }
}

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(KaizenHealthkitPlugin)
public class KaizenHealthkitPlugin: CAPPlugin {
    private let implementation = KaizenHealthkit()
    
    func getDateFromString(inputDate: String) -> Date{
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: inputDate)!
    }

    @objc func isAvailable(_ call: CAPPluginCall) {
        if HKHealthStore.isHealthDataAvailable() {
            return call.resolve()
        } else {
            return call.reject("Health data not available")
        }
    }

    func getType(name: String) -> HKQuantityType? {
        switch name {
        case "stepCount":
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        case "activeEnergyBurned":
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        case "weight":
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        case "heartRate":
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        case "oxygenSaturation":
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!
        default:
            return nil
        }
    }

    func getTypes(items: [String]) -> Set<HKSampleType> {
        var types: Set<HKSampleType> = []
        for item in items {
            switch item {
            case "stepCount":
                types.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
            case "sleepAnalysis":
                types.insert(HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!)
            case "activeEnergyBurned":
                types.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!)
            case "weight":
                types.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!)
            case "heartRate":
                 types.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!)
            case "oxygenSaturation":
                 types.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!)
            default:
                print("no match in case: " + item)
            }
        }
        return types
    }

    @objc func requestAuthorization(_ call: CAPPluginCall) {
        if !HKHealthStore.isHealthDataAvailable() {
            return call.reject("Health data not available")
        }
        guard let _all = call.options["all"] as? [String] else {
            return call.reject("Must provide all")
        }
        guard let _read = call.options["read"] as? [String] else {
            return call.reject("Must provide read")
        }
        guard let _write = call.options["write"] as? [String] else {
            return call.reject("Must provide write")
        }

        let writeTypes: Set<HKSampleType> = getTypes(items: _write).union(getTypes(items: _all))
        let readTypes: Set<HKSampleType> = getTypes(items: _read).union(getTypes(items: _all))

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, _ in
            if !success {
                call.reject("Could not get permission")
                return
            }
            call.resolve()
        }
    }

    func getStatisticsOptions(operations: [String]) -> HKStatisticsOptions {
        var ops: HKStatisticsOptions = []

        for operation in operations {
            switch operation {
            case "sum":
                ops.insert(.cumulativeSum)
            case "average":
                ops.insert(.discreteAverage)
            case "min":
                ops.insert(.discreteMin)
            case "max":
                ops.insert(.discreteMax)
            case "latest":
                ops.insert(.mostRecent)
            default:
                print("Error: unknown operation type")
            }
        }
        
        return ops
    }

    func generateReport(_quantityName: String, statistics: HKStatistics, operations: [String]) -> Dictionary<String, Any>? {
        var res: Dictionary<String, Any> = [:]
        var unit = HKUnit(from: "")

        for operation in operations {
            let quantity: HKQuantity

            switch operation {
            case "sum":
                guard let sum = statistics.sumQuantity() else { continue }
                quantity = sum
            case "average":
                guard let average = statistics.averageQuantity() else { continue }
                quantity = average
            case "min":
                guard let min = statistics.minimumQuantity() else { continue }
                quantity = min
            case "max":
                guard let max = statistics.maximumQuantity() else { continue }
                quantity = max
            case "latest":
                guard let latest = statistics.mostRecentQuantity() else { continue }
                quantity = latest
            default:
                print("Error: unknown operation type")
                continue
            }
            
            if (unit.isNull()) {
                let result = NormalizedQuantity(quantityType: _quantityName, quantity: quantity)
                unit = result.unit!
                res["unitName"] = result.unitName
                res[operation] = result.value
            } else {
                res[operation] = quantity.doubleValue(for: unit)
            }
        }
        
        return res
    }

    @objc func queryHKitStatistics(_ call: CAPPluginCall) {
        guard let _quantityName = call.options["quantityType"] as? String else {
            return call.reject("Must provide quantityType")
        }
        guard let startDateString = call.options["startDate"] as? String else {
            return call.reject("Must provide startDate")
        }
        guard let endDateString = call.options["endDate"] as? String else {
            return call.reject("Must provide endDate")
        }
        guard let operations = call.options["operations"] as? [String] else {
            return call.reject("Must provide operations")
        }
        
        let ops = getStatisticsOptions(operations: operations)

        let _startDate = getDateFromString(inputDate: startDateString)
        let _endDate = getDateFromString(inputDate: endDateString)

        let predicate = HKQuery.predicateForSamples(withStart: _startDate, end: _endDate, options: [])

        guard let quantityType: HKQuantityType = getType(name: _quantityName) else {
            return call.reject("Error in quantity type")
        }

        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: ops) {
            _, statisticsOrNil, errors in

            guard let statistics = statisticsOrNil else {
                // Handle any errors here.
                call.reject(errors?.localizedDescription ?? "")
                return
            }
            
            let res = self.generateReport(_quantityName: _quantityName, statistics: statistics, operations: operations) ?? [:]

            call.resolve(res)
        }
        healthStore.execute(query)
    }
}
