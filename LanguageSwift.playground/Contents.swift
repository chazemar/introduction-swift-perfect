import UIKit
//: # Swift overview - Dev Days
//: ## Concise syntax
var names = ["Christophe", "François"]

for name in names {
    print("Hello \(name)")
}

let filteredNames = names.filter { $0.contains("F") }
print(filteredNames)
//: ## Constants vs variables
let constant = "DevDays"
var variable = "DevDays"
variable += "2016"
//: ## Type safety and type inference
//: Swift encourages you to be clear about the types of values. It performs type checks when compiling code to fix errors early as possible
//: The LLVM compiler will deduce the type of an expression automatically when it compiles the code.
//: ### A initial value is provided, Swift can infer the type
let constantInference = "I am a string"
var variableInference = "I am also a string"
//: ### No initial value provided, you must specify the type
var newVariable: String
newVariable = "Hey me too !"
let pi = 3 + 0.14159 // inferred to be a Double
//: ## Tuples
//: Aggregate values into a single value
let score = (name: "François", points: 10)
print("Score: \(score.points) points for \(score.name)")
//: Useful to return several values of a function
func getScore() -> (name: String, points: Int) {
    return ("Christophe", 12)
}
let anotherScore = getScore()
print("Score: \(anotherScore.points) points for \(anotherScore.name)")
//: ## Optionals
// Use it when the value of a constant or a variable can be absent
// Can be used with any types
var age: Int? // nil is not a pointer, it indicates the absence of value
//: ###  Check if an optional has a value
age = 34
print("Age: \(age)") // Display optional type
//: 1) Forced unwrapping value
if age != nil {
    print("Age with forced unwrapping value: \(age!)") // Use ! to access to the value after a check
}
//: 2) Optional binding
if let ageValue = age {
    print("Age with optional binding: \(ageValue)") // Age value contains the value of age, no need to use !
}
var eyesColor: UIColor?
eyesColor = #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
if let ageValue = age, let eyesColorValue = eyesColor {
    print("Age \(ageValue) and eyes color \(eyesColorValue)")
}
//: ### Implicity unwrapped optional
//: Use it when you know that an optional will always have a value to remove the check in your code.
//: Used with Interface Builder outlets.
var gender: String!
gender = "M"
var implicitGender: String = gender
//: ### Optional chaining
//: Call methods, properties on an optional that can be nil.
//: If the optional contains a value, the method or property is called.
//: If the optional does not contain a value, the method or property return nil.
//: The result is always an optional.
class Person {
    var address: Address?
    
    init() {
        print("Person initializer")
    }
    
    deinit {
        print("Person deinitializer")
    }
}

class Address {
    var street: String?
    var city: City?
    
    func doSomething() {
        print("do some thing")
    }
}

class City {
    var name: String?
}

let person = Person()
if let street = person.address?.street {
    print("Street: \(street)")
} else {
    print("Can't retrieve the street")
}
let address = Address();
address.street = "Avenue Albert Durand"
let city = City()
city.name = "Blagnac"
address.city = city
person.address = address;

// Before: something like that
if person.address != nil && person.address?.city != nil && person.address?.city?.name != nil {
}
// Now: Optional chaining
if let city = person.address?.city?.name {
    print("City: \(city)")
} else {
    print("Can't retrieve the city")
}
if person.address?.doSomething() != nil {
    print("Call doSomething")
} else {
    print("Can't call doSomething")
}
//: ### Failable initializer
//: Initialization can fail
class Animal: NSObject {
    let species: String
    
    init?(species: String) {
        if species.isEmpty {
            return nil
        }
        self.species = species
    }
    
    override var description: String {
        return self.species
    }
}

let 🐶 = Animal(species: "Dog")
print(🐶)
//: ## Switch pattern matching
//: 1) Strings
let 🐱 = Animal(species: "Cat")
switch 🐱!.species {
    case "Dog":
        print("It's a dog")
    case "Cat":
        print("It's a cat")
    default:
        print("Unknown specy")
}
//: 2) Interval matching
let points = 10
var summary: String
switch points {
    case 0:
        summary = "Very bad score"
    case 1..<5:
        summary = "Low score"
    case 5..<10:
        summary = "Medium score"
    case 10..<15:
        summary = "High score"
    default:
        summary = "Unknown score"
}
print(summary)
//: 3) Tuples
switch score {
    case ("François", 10):
        print("François's score")
    default:
        print("Unknown score")
}
//: 4) Where
let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
switch view {
case _ where view.frame.size.width <= 50 && view.frame.size.height <= 50:
    print("small")
case _ where view.frame.size.width > 50 && view.frame.size.height > 50:
    print("large")
default:
    print("unknown size")
}
//: ## Extensions
//: Add new functionality to an existing class, structure, enumeration or protocol.
//: You can extend types for which you do not have access to the source code.
//: You can't override existing functionality or add stored properties.
extension String {
    var numberOfVowels: Int {
        get {
            let vowels = "aeiou"
            let strippedComponents = lowercased().components(separatedBy: CharacterSet(charactersIn: vowels))
            let stripped = strippedComponents.joined(separator: "")
            return characters.count - stripped.characters.count
        }
    }
    
    func printNumberOfVowels() {
        print(numberOfVowels)
    }
}
print("François".numberOfVowels)
"Christophe".printNumberOfVowels()
//: ## Protocols
//: A protocol specifies requirements with methods, properties.
//: Can be adpoted by classes, structures, enumumerations.
//: 1) Properties
protocol AnimalProtocol {
    var species: String { get }
}

class Bird: AnimalProtocol {
    var species: String {
        return "Bird"
    }
}
//: 2) Methods
protocol Vehicule {
    func horn()
}

class Bicycle: Vehicule {
    func horn() {
        print("DRING DRING")
    }
}

class Auto: Vehicule {
    func horn() {
        print("TUT TUT")
    }
}
//: Protocols are types
let vehicule: Vehicule?
vehicule = Auto()
//: ## Generics
//: Flexible, reusable functions and types
func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
    let temporaryA = a
    a = b
    b = temporaryA
}
var firstInt = 2
var secondInt = 5
swapTwoValues(&firstInt, &secondInt)
print("firstInt: \(firstInt), secondInt: \(secondInt)")
//: Constraint
func findIndex<T: Equatable>(of valueToFind: T, in array:[T]) -> Int? {
    for (index, value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}
//: ## Early exit using guard
//: Use guard to require that a condition must be true to execute the code after
func print(address: Address) {
    guard let addressStreet = address.street,
        let addressCity = address.city?.name else {
            print("no address to print")
            return
    }
    print("Full address: \(addressStreet) \(addressCity)")
}

let workAddress = Address()
workAddress.street = "Avenue Albert Durand"
print(address: workAddress)
let workCity = City()
workCity.name = "Blagnac"
workAddress.city = workCity
print(address: workAddress)
//: ## Cleanup actions
//: Use defer to execute code when execution leaves the current scope
func deferSample() -> Int {
    defer {
        print("deferSample : clean-up")
    }
    
    print("deferSample : 1st step")
    
    return 0
}

deferSample()
//: ## Error handling
//: Errors are represented by types that conforms to the Error protocol
//: Use try or try? or try! to call a method that throws an error
//: Unlike exception, Swift errors not unwind the call stack
enum SampleError: Error {
    case toosmall
    case toobig
}

func methodCanThrowErrors(number: Int) throws -> Int {
    guard number > 5 else {
        throw SampleError.toosmall
    }
    guard number < 20 else {
        throw SampleError.toobig
    }
    
    return number
}

func propagateError(_ number: Int) throws {
    try methodCanThrowErrors(number: number)
}

func testError(number: Int) {
    do {
        try propagateError(number)
    } catch SampleError.toosmall {
        print("Too small error")
    } catch SampleError.toobig {
        print("Too big error")
    } catch {
    }
}

testError(number: 5)
testError(number: 20)

let number = try? methodCanThrowErrors(number: 3)
print("try? number \(number)")

func disablepropagationError(_ number: Int) {
    try! methodCanThrowErrors(number: number)
}
//: ## Closures
//: Closures are code blocks that can be used in your code.
//: 3 styles: global functions, nested functions, closure expressions.
//: Closures can capture local constants and variables to use it later even if the original scope no longer exists (by value if not modified, by reference if modified)
//: 1) Use normal function
func sortFunction(_ s1: String, _ s2: String) -> Bool {
    return s1 > s2
}
print(names.sorted(by: sortFunction))
//: 2) Use inline closure expression
print(names.sorted(by: { (s1: String, s2: String) -> Bool in return s1 > s2 }))
//: 3) Use type inference to reduce the closure
print(names.sorted(by: { s1, s2 in return s1 > s2 }))
//: 4) No need to return for a single expression 
print(names.sorted(by: { s1, s2 in s1 > s2 }))
//: 5) Remove the arguments list with shorthand arguments
print(names.sorted(by: { $0 > $1 }))
//: 6) Use an operator with the same signature
print(names.sorted(by: >))
//: 7) Trailing closure if the closure expression is the last argument : Write the closure after
print(names.sorted() { $0 > $1 })

func doAsynchronousTask(completionHandler: ((Bool) -> Void)? = nil) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        completionHandler?(true)
    }
}

doAsynchronousTask { (success) in
    print("Task finished with success \(success)")
}
//: ### Higher-Order functions provided samples
print(names.filter { $0.contains("F") })
print(names.map { $0.lowercased() })

let scores = [0, 1, 2, 3, 4]
print(scores.reduce(0, { $0 + $1 }))
print(scores.reduce(0, +))
print(scores.filter{$0 % 2 == 0}.map{ $0 * $0 }.reduce(0, +))

//: ## Automatic Reference Counting (ARC)
//: Swift uses ARC to track and manage your app's memory.
//: In general, no need to think about memory management.
//: When an instance is no longer used, ARC frees the memory.
//: When you do an assignment, a strong reference is created.
//: The compiler will inject code to track the reference count of objects : if the reference count is zero, the object will be deallocated
var firstPerson: Person?
var secondPerson: Person?
var thirdPerson: Person?
firstPerson = Person() // 1 strong reference
secondPerson = firstPerson // 2 strong references
thirdPerson = firstPerson // 3 strong references
firstPerson = nil // 2 strong references
secondPerson = nil // 1 strong reference
thirdPerson = nil // 0 strong reference -> deallocate
//: No background process, values deallocated as soon as possible but the developer must manage retain cycles
//: ### Retain cycles
//: It's possible to write code in which an instance of a class never has zero strong reference
class Driver {
    var name: String
    var car: Car?
    
    init(name: String) {
        self.name = name
        print("Driver initializer")
    }
    
    deinit {
        print("Driver deinitializer")
    }
}
class Car {
    let name: String
    /*weak*/ var driver: Driver?
    
    init(name: String) {
        self.name = name
        print("Car initializer")
    }
    
    deinit {
        print("Car deinitializer")
    }
}

var driver: Driver?
driver = Driver(name: "François") // 1 strong reference to driver instance
var car: Car?
car = Car(name: "207") // 1 strong reference to car instance

driver!.car = car // 2 strong references to car instance
car!.driver = driver // 2 strong references to driver instance

driver = nil // Still 1 reference in car object -> not deallocated
car = nil // Still 1 reference in driver object -> not deallocated
//: There's a memory leak: how to resolve this?
//: We must use a weak reference : don't increment the reference counter, so it breaks the cycle.
//: If the instance is deallocated, the weak reference returns nil : we can test it





