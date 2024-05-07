/// An atom type that provides a read-write state value.
///
/// This atom provides a mutable state value that can be accessed from anywhere, and it notifies changes
/// to downstream atoms and views.
///
/// ## Output Value
///
/// Self.Value
///
/// ## Example
///
/// ```swift
/// struct CounterAtom: StateAtom, Hashable {
///     func defaultValue(context: Context) -> Int {
///         0
///     }
/// }
///
/// struct CounterView: View {
///     @WatchState(CounterAtom())
///     var count
///
///     var body: some View {
///         Stepper("Count: \(count)", value: $count)
///     }
/// }
/// ```
///
public protocol StateAtom: Atom {
    /// The type of value that this atom produces.
    associatedtype Value

    /// Creates a default value of the state to be provided via this atom.
    ///
    /// The value returned from this method will be the default state value. When this atom is reset,
    /// the state will revert to this value.
    ///
    /// - Parameter context: A context structure to read, watch, and otherwise
    ///                      interact with other atoms.
    ///
    /// - Returns: A default value of state.
    @MainActor
    func defaultValue(context: Context) -> Value
}

public extension StateAtom {
    var producer: AtomProducer<Value, Coordinator> {
        AtomProducer { context in
            context.transaction(defaultValue)
        }
    }
}
