//
//  MemoryProbe.swift
//  HarnessKitBenchmarks
//
//  Resident-set-size reader backed by mach_task_basic_info. Used to report
//  peak RSS deltas across a scenario run.
//

import Darwin
import Foundation

enum MemoryProbe {
    /// Current resident bytes reported by the kernel. Reads the task's
    /// `MACH_TASK_BASIC_INFO` record; returns 0 on failure (rare — we're
    /// asking about our own task).
    static func residentBytes() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size
        )
        let result = withUnsafeMutablePointer(to: &info) { infoPtr -> kern_return_t in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { reboundPtr in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), reboundPtr, &count)
            }
        }
        return result == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }

    /// Convenience: current resident megabytes.
    static func residentMB() -> Double {
        Double(residentBytes()) / (1024.0 * 1024.0)
    }
}
