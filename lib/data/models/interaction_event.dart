class InteractionEvent {
  final String itemId; // ID original del ítem
  final int
      timestamp; // Timestamp original del evento (ej. epoch en segundos o ms)

  InteractionEvent({
    required this.itemId,
    required this.timestamp,
  });
}
