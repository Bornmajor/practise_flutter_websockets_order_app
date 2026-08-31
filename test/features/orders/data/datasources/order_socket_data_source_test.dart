import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:practise_flutter_websockets_order_app/core/config/app_config.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/datasources/order_socket_data_source.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:stream_channel/stream_channel.dart';

void main() {
  late List<_FakeWebSocketChannel> channels;
  late OrderSocketDataSourceImpl dataSource;

  setUp(() {
    channels = [];
    dataSource = OrderSocketDataSourceImpl(
      appConfig: AppConfig(
        baseUrl: 'http://localhost:3000/api',
        apiKey: 'test-key',
        socketUrl: 'ws://localhost:3000',
      ),
      reconnectDelay: Duration.zero,
      channelFactory: (_) {
        final channel = _FakeWebSocketChannel();
        channels.add(channel);
        return channel;
      },
    );
  });

  tearDown(() => dataSource.close());

  test('emits an order model for a STATUS_UPDATE message', () async {
    final update = expectLater(
      dataSource.statusUpdates,
      emits(
        isA<dynamic>()
            .having((order) => order.orderId, 'orderId', 'ORD-1')
            .having((order) => order.status, 'status', 'PREPARING'),
      ),
    );

    channels.single.addIncoming(jsonEncode(_statusUpdate(orderId: 'ORD-1')));

    await update;
  });

  test('ignores CONNECTED messages', () async {
    final receivedOrders = <dynamic>[];
    final subscription = dataSource.statusUpdates.listen(receivedOrders.add);

    channels.single.addIncoming(
      jsonEncode({'event': 'CONNECTED', 'message': 'Subscribed'}),
    );
    await Future<void>.delayed(Duration.zero);

    expect(receivedOrders, isEmpty);
    await subscription.cancel();
  });

  test('emits an error for invalid JSON', () async {
    final error = expectLater(dataSource.statusUpdates, emitsError(isFormatException));

    channels.single.addIncoming('not-json');

    await error;
  });

  test('emits an error when STATUS_UPDATE has no order object', () async {
    final error = expectLater(dataSource.statusUpdates, emitsError(isFormatException));

    channels.single.addIncoming(jsonEncode({'event': 'STATUS_UPDATE'}));

    await error;
  });

  test('sends the expected order subscription frame', () {
    dataSource.subscribe('ORD-1');

    expect(
      jsonDecode(channels.single.sink.messages.single),
      {'action': 'subscribe', 'order_id': 'ORD-1'},
    );
  });

  test('reconnects and re-subscribes tracked orders after disconnect', () async {
    dataSource.subscribe('ORD-1');

    await channels.single.closeIncoming();
    await _waitFor(() => channels.length == 2);

    expect(
      jsonDecode(channels[1].sink.messages.single),
      {'action': 'subscribe', 'order_id': 'ORD-1'},
    );
  });

  test('close stops reconnecting and closes the active sink', () async {
    final channel = channels.single;

    await dataSource.close();
    await channel.closeIncoming();
    await Future<void>.delayed(Duration.zero);

    expect(channel.sink.isClosed, isTrue);
    expect(channels, hasLength(1));
  });
}

Map<String, dynamic> _statusUpdate({required String orderId}) {
  return {
    'event': 'STATUS_UPDATE',
    'order': {
      'order_id': orderId,
      'meal': 'Burger',
      'price': 12.5,
      'image_url': 'https://example.com/burger.jpg',
      'status': 'PREPARING',
      'created_at': '10:00 AM',
    },
  };
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('Timed out waiting for the WebSocket to reconnect.');
}

class _FakeWebSocketChannel extends DelegatingStreamChannel<dynamic>
    implements WebSocketChannel {
  factory _FakeWebSocketChannel() {
    final incomingController = StreamController<dynamic>();
    final sink = _FakeWebSocketSink();
    return _FakeWebSocketChannel._(incomingController, sink);
  }

  _FakeWebSocketChannel._(this._incomingController, this._sink)
    : super(StreamChannel<dynamic>(_incomingController.stream, _sink));

  final StreamController<dynamic> _incomingController;
  final _FakeWebSocketSink _sink;

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  @override
  Future<void> get ready => Future.value();

  @override
  _FakeWebSocketSink get sink => _sink;

  void addIncoming(dynamic message) {
    _incomingController.add(message);
  }

  Future<void> closeIncoming() => _incomingController.close();
}

class _FakeWebSocketSink implements WebSocketSink {
  final List<dynamic> messages = [];
  final Completer<void> _doneCompleter = Completer<void>();
  bool isClosed = false;

  @override
  void add(dynamic data) {
    if (!isClosed) messages.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<dynamic> stream) async {
    await for (final data in stream) {
      add(data);
    }
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    isClosed = true;
    if (!_doneCompleter.isCompleted) _doneCompleter.complete();
  }

  @override
  Future<void> get done => _doneCompleter.future;
}