protocol PathComponent: PathComponentConvertible {
  func matches(param: String) -> Bool
}

extension PathComponent {
  func pathComponent() -> PathComponent {
    return self
  }
}

protocol PathComponentConvertible {
  func pathComponent() -> PathComponent
}

struct StaticComponent: PathComponent {
  let label: String

  func matches(param: String) -> Bool {
    return param == label
  }
}

struct DynamicIntegerComponent: PathComponent {
  let label: String

  func matches(param: String) -> Bool {
    return Int(param) != nil
  }
}

struct DynamicStringComponent: PathComponent {
  let label: String

  func matches(param: String) -> Bool {
    return true
  }
}

extension String: PathComponentConvertible {
  func pathComponent() -> PathComponent {
    return StaticComponent(label: self)
  }
}

extension Int: PathComponentConvertible {
  func pathComponent() -> PathComponent {
    return StaticComponent(label: String(self))
  }
}

struct Path {
  let components: [PathComponent]

  init(_ components: [PathComponentConvertible]) {
    self.components = components.map {$0.pathComponent()}
  }

  func extract(path: String) -> [String:String]? {
    return nil
  }
}

extension Path: ArrayLiteralConvertible {
  typealias Element = PathComponentConvertible

  init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension Path: StringLiteralConvertible {
  init(components: PathComponentConvertible...) {
    self.init(components)
  }

  init(stringLiteral value: String) {
      self.components = [StaticComponent(label: value)]
  }

  init(extendedGraphemeClusterLiteral value: String) {
      self.components = [StaticComponent(label: value)]
  }

  init(unicodeScalarLiteral value: String) {
      self.components = [StaticComponent(label: value)]
  }
}

func intParam(label: String) -> PathComponentConvertible {
  return DynamicIntegerComponent(label: label)
}

func stringParam(label: String) -> PathComponentConvertible {
  return DynamicStringComponent(label: label)
}
