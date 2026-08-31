// Imports required Dart core libraries for handling asynchronous streams, timers, and JSON decoding.
import 'dart:async';
import 'dart:convert';

// Imports project configurations and data models.
import 'package:practise_flutter_websockets_order_app/core/config/app_config.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/models/order_item_model.dart';
// Imports the third-party WebSocket channel package to establish socket connections.
import 'package:web_socket_channel/web_socket_channel.dart';

/// Abstract class defining the contract for the WebSocket data source.
/// Follows Clean Architecture principles by exposing only required methods to repositories.
abstract class OrderSocketDataSource {
  /// Stream that emits order status updates as typed [OrderItemModel] objects.
  Stream<OrderItemModel> get statusUpdates;

  /// Subscribes the WebSocket connection to updates for a specific order ID.
  void subscribe(String orderId);

  /// Closes the connection and cleans up active resources.
  Future<void> close();
}

typedef WebSocketChannelFactory = WebSocketChannel Function(Uri uri);

/// Implementation of [OrderSocketDataSource] that manages active connections,
/// auto-reconnections, subscriptions, and message parsing.
class OrderSocketDataSourceImpl implements OrderSocketDataSource {
  /// Constructor that accepts [AppConfig] to parse the WebSocket URI and initiates the first connection.
  OrderSocketDataSourceImpl({
    required AppConfig appConfig,
    WebSocketChannelFactory? channelFactory,
    this._reconnectDelay = const Duration(seconds: 3),
  })  : _socketUri = Uri.parse(appConfig.socketUrl),
        _channelFactory = channelFactory ?? WebSocketChannel.connect {
    _connect();
  }

  // The parsed URI pointing to the WebSocket server.
  final Uri _socketUri;
  final WebSocketChannelFactory _channelFactory;
  final Duration _reconnectDelay;

  // StreamController used to emit parsed order updates to multiple listeners (broadcast stream).
  final StreamController<OrderItemModel> _statusUpdatesController =
      StreamController<OrderItemModel>.broadcast();

  // In-memory set holding unique order IDs so subscriptions can be re-sent automatically upon reconnection.
  final Set<String> _subscribedOrderIds = {};

  // Holds the active WebSocket channel instance.
  WebSocketChannel? _channel;

  // Holds the active stream subscription listening to incoming raw WebSocket messages.
  StreamSubscription<dynamic>? _channelSubscription;

  // Timer instance used to manage delayed auto-reconnection attempts.
  Timer? _reconnectTimer;

  // Guard flag indicating if this data source has been permanently disposed/closed.
  bool _isClosed = false;

  /// Exposes the broadcast stream for external layers (e.g., Repositories) to listen to order updates.
  @override
  Stream<OrderItemModel> get statusUpdates => _statusUpdatesController.stream;

  /// Establishes or re-establishes a WebSocket connection to the server.
  void _connect() {
    // Prevent reconnect attempts if the data source was intentionally closed.
    if (_isClosed) return;

    // Connect to the WebSocket endpoint using the stored URI.
    final channel = _channelFactory(_socketUri);
    _channel = channel;

    // Listen to incoming messages, stream errors, and stream completion (disconnection).
    _channelSubscription = channel.stream.listen(
      _handleMessage, // Invoked when a raw message is received.
      onError: (Object error, StackTrace stackTrace) {
        // Forward raw stream errors to the main status update controller.
        _statusUpdatesController.addError(error, stackTrace);
        // Treat the error the same as a disconnect so reconnect logic runs.
        _handleDisconnected();
      },
      onDone: _handleDisconnected, // Invoked when the socket connection drops or completes.
    );

    // Re-send subscription payloads for all tracked order IDs after reconnecting.
    for (final orderId in _subscribedOrderIds) {
      _sendSubscription(orderId);
    }
  }

  /// Schedules a reconnection attempt after a 3-second delay.
  void _scheduleReconnect() {
    // Don't schedule if the data source is closed or a reconnect timer is already active.
    if (_isClosed || _reconnectTimer?.isActive == true) return;

    // Wait before attempting to reconnect via _connect().
    _reconnectTimer = Timer(_reconnectDelay, _connect);
  }

  /// Handles disconnection logic when the socket stream finishes (`onDone`).
  void _handleDisconnected() {
    // Clear dead channel and subscription references.
    _channel = null;
    _channelSubscription = null;

    // Trigger the reconnect scheduler.
    _scheduleReconnect();
  }

  /// Processes raw incoming messages from the WebSocket connection.
  void _handleMessage(dynamic message) {
    // Validate that the incoming payload is a String (raw JSON text).
    if (message is! String) {
      _statusUpdatesController.addError(
        const FormatException('WebSocket message must be a JSON string.'),
      );
      return;
    }

    try {
      // Parse the JSON string into dynamic Dart objects.
      final decodedMessage = jsonDecode(message);

      // Ensure the decoded object is a JSON map/dictionary.
      if (decodedMessage is! Map<String, dynamic>) {
        throw const FormatException(
          'WebSocket message must be a JSON object.',
        );
      }

      // Check if the event type matches "STATUS_UPDATE".
      if (decodedMessage['event'] == 'STATUS_UPDATE') {
        final order = decodedMessage['order'];

        // Ensure the order field contains a valid JSON map.
        if (order is! Map<String, dynamic>) {
          throw const FormatException(
            'STATUS_UPDATE must include an order object.',
          );
        }

        // Map the JSON map to an [OrderItemModel] instance and emit it to the stream.
        _statusUpdatesController.add(OrderItemModel.fromJson(order));
      }
    } catch (error, stackTrace) {
      // Forward any parsing or validation errors to the controller's error channel.
      _statusUpdatesController.addError(error, stackTrace);
    }
  }

  /// Registers an order ID for updates and sends the subscribe frame to the server.
  @override
  void subscribe(String orderId) {
    // Track order ID locally to maintain subscription state across reconnects.
    _subscribedOrderIds.add(orderId);

    // Send the JSON subscription frame to the socket connection.
    _sendSubscription(orderId);
  }

  /// Helper method that encodes and sends the subscription payload over the active socket connection.
  void _sendSubscription(String orderId) {
    _channel?.sink.add(
      jsonEncode({'action': 'subscribe', 'order_id': orderId}),
    );
  }

  /// Cleans up resources, cancels active timers/subscriptions, and closes the socket and stream controller.
  @override
  Future<void> close() async {
    // Mark instance as closed to prevent further reconnect attempts.
    _isClosed = true;

    // Cancel active reconnection timer if one exists.
    _reconnectTimer?.cancel();

    // Cancel subscription to the active WebSocket channel.
    await _channelSubscription?.cancel();

    // Close the underlying WebSocket channel connection.
    await _channel?.sink.close();

    // Close the internal stream controller to notify listeners that no more updates will be emitted.
    await _statusUpdatesController.close();
  }
}