//
//  BezelResolutionStress.swift
//  HarnessKitBenchmarks
//
//  Witnesses the cumulative effect of §S5.1 (regex pre-compile),
//  §S5.2 (O(1) bezel-key tables), §S5.3 (lock-free GenerationCache builder),
//  §S5.4 (manifest prefix index), §S5.6 (JSON byte cache). Iterates
//  every descriptor catalogue (`DeviceDescriptor.allPhone` / `.allPad` /
//  `.allTV` / `.allVision`, `MacDeviceDescriptor.all`, `WatchDeviceDescriptor.all`)
//  on every iteration. After iter 1, all six are GenerationCache fast-path
//  hits — this measures the steady-state catalogue access cost that
//  Framely's batch flow pays once per item.
//
//  Cold-path measurement (with `invalidateCaches()` between iterations)
//  would require making `Scenario.run()` async — deferred.
//

import Foundation
import HarnessKitTransform

final class BezelResolutionStress: Scenario, @unchecked Sendable {
    let name = "BezelResolutionStress-CatalogueAccess"
    let iterations = 1000

    func run() throws -> PlatformImage? {
        var sink = 0
        sink &+= DeviceDescriptor.allPhone.count
        sink &+= DeviceDescriptor.allPad.count
        sink &+= DeviceDescriptor.allTV.count
        sink &+= DeviceDescriptor.allVision.count
        sink &+= MacDeviceDescriptor.all.count
        sink &+= WatchDeviceDescriptor.all.count
        precondition(sink > 0)
        return nil
    }
}
