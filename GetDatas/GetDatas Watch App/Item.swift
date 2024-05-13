import Foundation
import HealthKit
import WatchConnectivity

class WorkoutSessionManager: NSObject, HKWorkoutSessionDelegate {
    let healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    
    func startWorkout() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown
        
        do {
            workoutSession = try HKWorkoutSession(configuration: workoutConfiguration)
            workoutSession?.delegate = self
            healthStore.start(workoutSession!)
        } catch {
            // Handle error
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Handle session failure
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        // Handle session events
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle session state changes
    }
}


extension WorkoutSessionManager {
    func saveHeartRateSample(heartRate: Double) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: heartRate)
        let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: Date(), end: Date())
        
        healthStore.save(heartRateSample) { (success, error) in
            if success {
                // Heart rate sample saved successfully
            } else {
                // Handle error
            }
        }
    }
}
