enum OperationType { add, update, delete }

class PendingOperation<T> {
  final OperationType type;
  final dynamic key; // ID أو tempId
  final T payload;

  PendingOperation({
    required this.type,
    required this.key,
    required this.payload,
  });

  bool isConflictWith(PendingOperation<T> other) {
    return key == other.key &&
        ((type == OperationType.add && other.type == OperationType.delete) ||
         (type == OperationType.delete && other.type == OperationType.add));
  }
}
