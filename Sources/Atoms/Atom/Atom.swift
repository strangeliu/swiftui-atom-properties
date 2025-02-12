/// Declares that a type can produce a value that can be accessed from everywhere.
///
/// The value produced by an atom is created only when the atom is watched from somewhere,
/// and is immediately released when no longer watched to.
///
/// If the atom value needs to be preserved even if no longer watched to, you can consider
/// conform the ``KeepAlive`` protocol to the atom.
public protocol Atom {
    /// A type representing the stable identity of this atom.
    associatedtype Key: Hashable

    /// A loader type that represents an actual implementation of the corresponding atom.
    associatedtype Loader: AtomLoader where Loader.Coordinator == Coordinator

    /// A type to coordinate with the atom.
    associatedtype Coordinator = Void

    /// A type of the context structure that to read, watch, and otherwise interacting
    /// with other atoms.
    typealias Context = AtomTransactionContext<Coordinator>

    /// A type of the structure that to read value other atoms.
    typealias Reader = AtomReader

    /// A boolean value indicating whether the atom value should be preserved even if
    /// no longer watched to.
    ///
    /// It's recommended to conform the ``KeepAlive`` to this atom, instead of overriding
    /// this property to return `true`.
    /// The default is `false`.
    static var shouldKeepAlive: Bool { get }

    /// A unique value used to identify the atom internally.
    ///
    /// This key don't have to be unique with respect to other atoms in the entire application
    /// because it is identified respecting the metatype of this atom.
    /// If this atom conforms to `Hashable`, it will adopt itself as the `key` by default.
    var key: Key { get }

    /// Creates the custom coordinator instance that you use to preserve arbitrary state of
    /// the atom.
    ///
    /// It's called when the atom is initialized, and the same instance is preserved until
    /// the atom is no longer used and is deinitialized.
    ///
    /// - Returns: The atom's associated coordinator instance.
    @MainActor
    func makeCoordinator() -> Coordinator

    /// Notifies the atom that the associated value is updated.
    ///
    /// Use it to manage arbitrary side-effects of value updates, such as state persistence,
    /// state synchronization, logging, and etc.
    /// You can also access other atom values via `reader` passed as a parameter.
    ///
    /// - Parameters:
    ///   - newValue: A new value after update.
    ///   - oldValue: An old value before update.
    ///   - reader: A structure that to read value other atoms.
    @MainActor
    func updated(newValue: Loader.Value, oldValue: Loader.Value, reader: Reader)

    // --- Internal ---

    /// A loader that represents an actual implementation of the corresponding atom.
    @MainActor
    var _loader: Loader { get }
}

public extension Atom {
    static var shouldKeepAlive: Bool {
        false
    }

    func makeCoordinator() -> Coordinator where Coordinator == Void {
        ()
    }

    func updated(newValue: Loader.Value, oldValue: Loader.Value, reader: Reader) {}
}

public extension Atom where Self == Key {
    var key: Self {
        self
    }
}
