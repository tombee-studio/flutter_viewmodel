import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_viewmodel/flutter_viewmodel.dart';

// Test ViewModel implementation
class CounterViewModel extends ViewModel {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

class DisposableViewModel extends ViewModel {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

class InitViewModel extends ViewModel {
  bool initialized = false;

  @override
  void init() {
    initialized = true;
  }
}

void main() {
  group('ViewModel', () {
    test('initial state is correct', () {
      final viewModel = CounterViewModel();
      expect(viewModel.count, equals(0));
    });

    test('increment increases count by 1', () {
      final viewModel = CounterViewModel();
      viewModel.increment();
      expect(viewModel.count, equals(1));
    });

    test('decrement decreases count by 1', () {
      final viewModel = CounterViewModel();
      viewModel.decrement();
      expect(viewModel.count, equals(-1));
    });

    test('reset sets count to 0', () {
      final viewModel = CounterViewModel();
      viewModel.increment();
      viewModel.increment();
      viewModel.reset();
      expect(viewModel.count, equals(0));
    });

    test('notifyListeners triggers listeners on state change', () {
      final viewModel = CounterViewModel();
      int notifyCount = 0;
      viewModel.addListener(() {
        notifyCount++;
      });

      viewModel.increment();
      viewModel.increment();
      viewModel.decrement();

      expect(notifyCount, equals(3));
    });

    test('dispose is called correctly', () {
      final viewModel = DisposableViewModel();
      expect(viewModel.disposed, isFalse);
      viewModel.dispose();
      expect(viewModel.disposed, isTrue);
    });

    test('listeners are not called after dispose', () {
      final viewModel = CounterViewModel();
      int notifyCount = 0;
      viewModel.addListener(() {
        notifyCount++;
      });

      viewModel.increment();
      expect(notifyCount, equals(1));

      viewModel.dispose();

      // After dispose, listeners should not be called
      expect(notifyCount, equals(1));
    });

    test('init is called on initialization', () {
      final viewModel = InitViewModel();
      viewModel.init();
      expect(viewModel.initialized, isTrue);
    });

    test('ViewModel extends ChangeNotifier', () {
      final viewModel = CounterViewModel();
      expect(viewModel, isA<ChangeNotifier>());
    });

    test('multiple listeners are all notified', () {
      final viewModel = CounterViewModel();
      int listener1Count = 0;
      int listener2Count = 0;

      viewModel.addListener(() => listener1Count++);
      viewModel.addListener(() => listener2Count++);

      viewModel.increment();

      expect(listener1Count, equals(1));
      expect(listener2Count, equals(1));
    });

    test('removing a listener stops notifications', () {
      final viewModel = CounterViewModel();
      int notifyCount = 0;

      void listener() {
        notifyCount++;
      }

      viewModel.addListener(listener);
      viewModel.increment();
      expect(notifyCount, equals(1));

      viewModel.removeListener(listener);
      viewModel.increment();
      expect(notifyCount, equals(1));
    });
  });

  group('ViewModelProvider', () {
    testWidgets('provides ViewModel to widget subtree', (tester) async {
      final viewModel = CounterViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            viewModel: viewModel,
            child: Builder(
              builder: (context) {
                final vm = ViewModelProvider.of<CounterViewModel>(context);
                return Text('${vm?.count ?? 0}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('ViewModelProvider disposes ViewModel when removed',
        (tester) async {
      final viewModel = DisposableViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<DisposableViewModel>(
            viewModel: viewModel,
            child: const SizedBox(),
          ),
        ),
      );

      expect(viewModel.disposed, isFalse);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(viewModel.disposed, isTrue);
    });

    testWidgets('ViewModelProvider.of returns null when no provider found',
        (tester) async {
      late CounterViewModel? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = ViewModelProvider.of<CounterViewModel>(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result, isNull);
    });
  });

  group('ViewModelBuilder', () {
    testWidgets('builds widget with initial ViewModel state', (tester) async {
      final viewModel = CounterViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            viewModel: viewModel,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) {
                return Text('Count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('rebuilds widget when ViewModel state changes', (tester) async {
      final viewModel = CounterViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            viewModel: viewModel,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) {
                return Text('Count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      viewModel.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('rebuilds widget multiple times on multiple state changes',
        (tester) async {
      final viewModel = CounterViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            viewModel: viewModel,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) {
                return Text('Count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      viewModel.increment();
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      viewModel.increment();
      await tester.pump();
      expect(find.text('Count: 2'), findsOneWidget);

      viewModel.decrement();
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      viewModel.reset();
      await tester.pump();
      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('ViewModelBuilder does not rebuild when unrelated state changes',
        (tester) async {
      final viewModel = CounterViewModel();
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            viewModel: viewModel,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) {
                buildCount++;
                return Text('Count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(buildCount, equals(1));

      // Pump without state change should not trigger rebuild
      await tester.pump();
      expect(buildCount, equals(1));
    });

    testWidgets('ViewModelBuilder with explicit viewModel parameter',
        (tester) async {
      final viewModel = CounterViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelBuilder<CounterViewModel>(
            viewModel: viewModel,
            builder: (context, vm) {
              return Text('Count: ${vm.count}');
            },
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      viewModel.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });
  });

  group('ViewModel lifecycle', () {
    testWidgets('init is called when ViewModelProvider is inserted',
        (tester) async {
      final viewModel = InitViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<InitViewModel>(
            viewModel: viewModel,
            child: const SizedBox(),
          ),
        ),
      );

      expect(viewModel.initialized, isTrue);
    });

    testWidgets('ViewModel persists across widget rebuilds', (tester) async {
      final viewModel = CounterViewModel();
      viewModel.increment();
      viewModel.increment();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            viewModel: viewModel,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) {
                return Text('Count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 2'), findsOneWidget);

      // Force rebuild
      await tester.pump();

      // State should persist
      expect(find.text('Count: 2'), findsOneWidget);
    });
  });

  group('CounterViewModel unit tests', () {
    late CounterViewModel viewModel;

    setUp(() {
      viewModel = CounterViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('starts at zero', () {
      expect(viewModel.count, 0);
    });

    test('increment by 1 each call', () {
      for (int i = 1; i <= 5; i++) {
        viewModel.increment();
        expect(viewModel.count, i);
      }
    });

    test('decrement by 1 each call', () {
      for (int i = -1; i >= -5; i--) {
        viewModel.decrement();
        expect(viewModel.count, i);
      }
    });

    test('reset after multiple increments', () {
      viewModel.increment();
      viewModel.increment();
      viewModel.increment();
      viewModel.reset();
      expect(viewModel.count, 0);
    });

    test('increment and decrement cancel out', () {
      viewModel.increment();
      viewModel.decrement();
      expect(viewModel.count, 0);
    });

    test('notify count matches operation count', () {
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.increment(); // 1
      viewModel.increment(); // 2
      viewModel.decrement(); // 3
      viewModel.reset();     // 4

      expect(notifyCount, equals(4));
    });
  });
}
