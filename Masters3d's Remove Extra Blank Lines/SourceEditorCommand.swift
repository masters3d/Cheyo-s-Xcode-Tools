//
//  SourceEditorCommand.swift
//  Masters3d's Remove Extra Blank Lines
//
//  Created by Cheyo Jimenez on 8/12/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    private func convert(_ nsStringArray:NSArray) -> [String] {
        var result = [String]()
        for each in nsStringArray {
            guard let eachString = each as? String else {return []}
            result.append(eachString)
        }
        return result
    }
    
    // we only select if there is more one blank line
    private func selectLines(_ possibleBlankLines:[Int]) -> [Int] {
        var result = [Int]()
        // if the input is empty we bail out
        guard var previousIndex = possibleBlankLines.first else {
            return [] }
        for index in possibleBlankLines {
            if previousIndex + 1 == index {
                result.append(index)
            }
            previousIndex = index
        }
        return result
    }
    
    // return all blank lines
    private func allBlankLines(_ lines:[String]) -> [Int] {
        var blankLines = [Int]()
        for (index, content) in lines.enumerated() {
          if  content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                blankLines.append(index)
            }
        }
        return blankLines
    }
    
    // return index of items to remove
    func linesToRemove(_ nsarray: NSArray) -> [Int] {
        let lines = convert(nsarray)
        return selectLines(allBlankLines(lines))
        }
    
    func blankLinesLeftBehind(_ nsarray: NSArray) -> Set<Int> {
        return Set(allBlankLines(convert(nsarray))).symmetricDifference(linesToRemove(nsarray))
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    
        let lines = invocation.buffer.lines
        
        let selectedToRemove = linesToRemove(lines)
        invocation.buffer.lines.removeObjects(at: IndexSet(selectedToRemove))
        
        // Update the selection of lines that were changed
        let updatedLines:[XCSourceTextRange] = blankLinesLeftBehind(lines).flatMap {
            let lineSelection = XCSourceTextRange()
            lineSelection.start  = XCSourceTextPosition(line: $0, column: 0)
            lineSelection.end = XCSourceTextPosition(line: $0 + 1, column: 0)
            return lineSelection
        }
        
        invocation.buffer.selections.setArray(updatedLines)
        // Finish Command
        completionHandler(nil)
    }
    
}
