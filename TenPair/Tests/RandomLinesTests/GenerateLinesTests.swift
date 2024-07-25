import XCTest
@testable import RandomLines

final class GenerateLinesTests: XCTestCase {
  func testGenerate500Lines() {
    let lines = RandomLines(lines: 500)
    measure {
      _ = lines.generate()
    }
  }

  func testGenerate20() {
    let random = RandomLines(lines: 20)
    let tiles = random.generate()
    let lines = tiles.chunked(into: 9)
    for line in lines {
      var lineString = " "
      for number in line {
        lineString += "\(number) "
      }
      print(lineString)
    }
  }
}

extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}
