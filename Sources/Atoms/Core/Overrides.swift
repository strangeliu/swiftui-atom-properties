@MainActor
internal struct Overrides {
    private var _entriesForNode = [AtomKey: AtomOverrideBase]()
    private var _entriesForType = [AtomTypeKey: AtomOverrideBase]()

    nonisolated init() {}

    mutating func insert<Node: Atom>(
        _ atom: Node,
        with value: @escaping (Node) -> Node.Loader.Value
    ) {
        let key = AtomKey(atom)
        _entriesForNode[key] = AtomOverride(value: value)
    }

    mutating func insert<Node: Atom>(
        _ atomType: Node.Type,
        with value: @escaping (Node) -> Node.Loader.Value
    ) {
        let key = AtomTypeKey(atomType)
        _entriesForType[key] = AtomOverride(value: value)
    }

    func value<Node: Atom>(for atom: Node) -> Node.Loader.Value? {
        let key = AtomKey(atom)
        let baseOverride = _entriesForNode[key] ?? _entriesForType[key.typeKey]

        guard let baseOverride = baseOverride else {
            return nil
        }

        guard let override = baseOverride as? AtomOverride<Node> else {
            assertionFailure(
                """
                [Atoms]
                Detected an illegal override.
                There might be duplicate keys or logic failure.
                Detected: \(type(of: self))
                Expected: AtomOverride<\(Node.self)>
                """
            )

            return nil
        }

        return override.value(atom)
    }
}

@MainActor
internal protocol AtomOverrideBase {}

internal struct AtomOverride<Node: Atom>: AtomOverrideBase {
    let value: (Node) -> Node.Loader.Value
}
