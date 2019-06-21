//
//  GPXExtensions.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import Foundation

/**
 For adding an extension tag.
 
 If extended, tags should be inbetween the open and close tags of **\<extensions>**
 */
open class GPXExtensions: GPXElement, Codable {
    
    /// for attributes without parent tags
    private var rootAttributes = [String : String]()
    
    /// for attributes with parent tags
    private var childAttributes = [String : [String : String]]()
    
    // MARK:- Initializers
    public required init() {
        super.init()
    }
    
    public subscript(parentTag: String?) -> [String : String]? {
        get {
            guard let parentTag = parentTag else {
                return rootAttributes
            }
            return childAttributes[parentTag]
        }
    }
    
    // MARK:- Tag
    override func tagName() -> String {
        return "extensions"
    }
    
    /// for GPXParser use only.
    init(dictionary: [String : String]) {
        var dictionary = dictionary
        var attributes = [[String : String]]()
        var elementNames = [Int : String]()
        
        for key in dictionary.keys {
            let keySegments = key.components(separatedBy: ", ")
            if keySegments.count == 2 {
                let index = Int(keySegments[1])!
                let elementName = keySegments[0]
                let value = dictionary[key]
                
                while !attributes.indices.contains(index) {
                    attributes.append([String : String]())
                }
                
                if value == "internalParsingIndex \(index)" {
                    elementNames[index] = elementName
                }
                else {
                    attributes[index][elementName] = value
                }
            }
            // ignore any key that does not conform to GPXExtension's parsing naming convention.
        }
        if elementNames.isEmpty {
            rootAttributes = attributes[0]
        }
        else {
            for elementNameIndex in elementNames.keys {
                let value = elementNames[elementNameIndex]!
                childAttributes[value] = attributes[elementNameIndex]
            }
        }
        
    }
    
    // MARK:- For Creation
    
    /// Insert a dictionary of extension objects
    public func insert(withParentTag tag: String?, withContents contents: [String : String]) {
        guard let tag = tag else {
            self.rootAttributes = contents
            return
        }
        self.childAttributes[tag] = contents
    }
    
    /// Remove a dictionary of extension objects
    public func remove(contentsOfParentTag tag: String?) {
        guard let tag = tag else {
            self.rootAttributes.removeAll()
            return
        }
        self.childAttributes[tag] = nil
    }
    
    // MARK:- GPX
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)

        for key in rootAttributes.keys {
            gpx.appendFormat("%@<%@>%@</%@>\r\n", indent(forIndentationLevel: indentationLevel + 1), key, rootAttributes[key] ?? "", key)
        }
        
        for key in childAttributes.keys {
            let newIndentationLevel = indentationLevel + 1
            gpx.append(String(format: "%@<%@>\r\n", indent(forIndentationLevel: newIndentationLevel), key))
            for childKey in childAttributes[key]!.keys {
                gpx.appendFormat("%@<%@>%@</%@>\r\n", indent(forIndentationLevel: newIndentationLevel + 1), childKey, childAttributes[key]![childKey] ?? "", childKey)
            }
            gpx.append(String(format: "%@</%@>\r\n", indent(forIndentationLevel: newIndentationLevel), key))
        }
        
    }
}
