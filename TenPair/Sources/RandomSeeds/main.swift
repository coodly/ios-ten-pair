import ArgumentParser
import Foundation
import GameKit
import SWLogger

Log.level = .debug
Log.add(output: ConsoleOutput())

struct Task: ParsableCommand {
    @Argument(help: "Number of lines")
    var lines = 20
    
    @Argument(help: "Number of seeds")
    var seeds = 100
    

    func run() throws {
        Log.debug("Generate \(seeds) seeds for \(lines) lines")
        
        var generated = [UInt64]()
        var checked = [UInt64]()
        repeat {
            let random = UInt64.random(in: 0..<UInt64.max)
            if checked.contains(random) {
                continue
            }
            
            checked.append(random)
            let source = GKMersenneTwisterRandomSource(seed: random)
            
        } while generated.count < seeds
    }
}

Task.main()
