import Foundation

var stack = [Chip]()
let condition = NSCondition()
var available = false
var interval = 2.0

public struct Chip {
    
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let chipType: ChipType
    
    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        
        return Chip(chipType: chipType)
    }
    
    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

public class Generating: Thread {
    
    public override func main() {
        print("Generation thread begin work")

        for _ in 1...10 {
            condition.lock()
            stack.append(Chip.make())
            print("I create \(stack.count) - count element in stack")
            available = true
            condition.signal()
            condition.unlock()
            Generating.sleep(forTimeInterval: interval)
            
            if Thread.current.isCancelled {
                print("Generation thread stop")
                return
            }
        }
        
    }
}

public class Worker: Thread {
    
    public override func main() {
        print("Worker thread begin work")
        for _ in 1...10 {
            while (!available) {
                condition.wait()
            }
            stack.removeFirst().sodering()
            print("Remove from the stack. \(stack.count) - count element in stack")
            if stack.count < 1 {
                available = false
                print("Worker thread stop")
            }
        }
    }
    
}

var generate = Generating()
var worker = Worker()

generate.start()
worker.start()

