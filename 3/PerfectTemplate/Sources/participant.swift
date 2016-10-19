//
//  participant.swift
//  PerfectTemplate
//
//  Created by Christophe Azemar on 12/10/2016.
//
//
import PerfectLib

class Participant : JSONConvertibleObject {
    var name = ""
    var job = ""
    
    override init() {}
    
    init(name : String, job : String) {
        self.name = name
        self.job = job
    }
    
    override public func getJSONValues() -> [String : Any] {
        return [
            "name":name,
            "job":job
        ]
    }
    
    override public func setJSONValues(_ values: [String : Any]) {
        self.name = getJSONValue(named: "name", from: values, defaultValue:"")
        self.job = getJSONValue(named: "job", from:values, defaultValue:"")
    }
}
