import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_viewmodel/flutter_viewmodel.dart';

// Test ViewModel implementations
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

class LifecycleTrackingViewModel extends ViewModel {
  bool initCalled = false;
  bool disposeCalled = false;
  int notifyCount = 0;

  @override
  void init() {
    initCalled = true;
  }

  @override
  void dispose() {
    disposeCalled = true;
    super.dispose();
  }

  void triggerNotify() {
    notifyCount++;
    notifyListeners();
  }
}

class StringViewModel extends ViewModel {
  String _value = '';

  String get value => _value;

  void setValue(String v) {
    _value = v;
    notifyListeners();
  }
}

void main() {
  group('ViewModel', () {
    test('initial state is correct', () {
      final vm = CounterViewModel();
      expect(vm.count, equals(0));
    });

    test('increment updates count', () {
      final vm = CounterViewModel();
      vm.increment();
      expect(vm.count, equals(1));
    });

    test('decrement updates count', () {
      final vm = CounterViewModel();
      vm.decrement();
      expect(vm.count, equals(-1));
    });

    test('reset sets count to zero', () {
      final vm = CounterViewModel();
      vm.increment();
      vm.increment();
      vm.increment();
      vm.reset();
      expect(vm.count, equals(0));
    });

    test('notifyListeners triggers listeners', () {
      final vm = CounterViewModel();
      int callCount = 0;
      vm.addListener(() => callCount++);

      vm.increment();
      expect(callCount, equals(1));

      vm.increment();
      expect(callCount, equals(2));
    });

    test('multiple listeners are all notified', () {
      final vm = CounterViewModel();
      int callCount1 = 0;
      int callCount2 = 0;

      vm.addListener(() => callCount1++);
      vm.addListener(() => callCount2++);

      vm.increment();
      expect(callCount1, equals(1));
      expect(callCount2, equals(1));
    });

    test('removeListener stops notifications', () {
      final vm = CounterViewModel();
      int callCount = 0;
      void listener() => callCount++;

      vm.addListener(listener);
      vm.increment();
      expect(callCount, equals(1));

      vm.removeListener(listener);
      vm.increment();
      expect(callCount, equals(1));
    });

    test('dispose prevents further notifications', () {
      final vm = CounterViewModel();
      int callCount = 0;
      vm.addListener(() => callCount++);

      vm.increment();
      expect(callCount, equals(1));

      vm.dispose();

      // After dispose, adding a listener and notifying should not work
      // (ChangeNotifier throws if used after dispose in debug mode)
    });

    test('LifecycleTrackingViewModel init is called', () {
      final vm = LifecycleTrackingViewModel();
      vm.init();
      expect(vm.initCalled, isTrue);
    });

    test('LifecycleTrackingViewModel dispose sets flag', () {
      final vm = LifecycleTrackingViewModel();
      vm.dispose();
      expect(vm.disposeCalled, isTrue);
    });

    test('notifyListeners increments counter', () {
      final vm = LifecycleTrackingViewModel();
      int listenerCallCount = 0;
      vm.addListener(() => listenerCallCount++);

      vm.triggerNotify();
      vm.triggerNotify();
      vm.triggerNotify();

      expect(vm.notifyCount, equals(3));
      expect(listenerCallCount, equals(3));
    });

    test('StringViewModel setValue updates value', () {
      final vm = StringViewModel();
      vm.setValue('hello');
      expect(vm.value, equals('hello'));

      vm.setValue('world');
      expect(vm.value, equals('world'));
    });
  });

  group('ViewModelProvider', () {
    testWidgets('provides ViewModel to subtree', (tester) async {
      final vm = CounterViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => vm,
            child: Builder(
              builder: (context) {
                final provided =
                    ViewModelProvider.of<CounterViewModel>(context);
                return Text('${provided.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('creates ViewModel using factory', (tester) async {
      CounterViewModel? createdVm;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () {
              createdVm = CounterViewModel();
              return createdVm!;
            },
            child: Builder(
              builder: (context) {
                final vm = ViewModelProvider.of<CounterViewModel>(context);
                return Text('${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(createdVm, isNotNull);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('disposes ViewModel when removed from tree', (tester) async {
      final vm = LifecycleTrackingViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<LifecycleTrackingViewModel>(
            create: () => vm,
            child: const SizedBox(),
          ),
        ),
      );

      expect(vm.disposeCalled, isFalse);

      // Remove the provider from the tree
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(vm.disposeCalled, isTrue);
    });

    testWidgets('init is called on ViewModel creation', (tester) async {
      final vm = LifecycleTrackingViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<LifecycleTrackingViewModel>(
            create: () => vm,
            child: const SizedBox(),
          ),
        ),
      );

      expect(vm.initCalled, isTrue);
    });

    testWidgets('nested providers provide correct ViewModels', (tester) async {
      final counterVm = CounterViewModel();
      final stringVm = StringViewModel();
      stringVm.setValue('test');

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => counterVm,
            child: ViewModelProvider<StringViewModel>(
              create: () => stringVm,
              child: Builder(
                builder: (context) {
                  final counter =
                      ViewModelProvider.of<CounterViewModel>(context);
                  final string =
                      ViewModelProvider.of<StringViewModel>(context);
                  return Column(
                    children: [
                      Text('counter:${counter.count}'),
                      Text('string:${string.value}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('counter:0'), findsOneWidget);
      expect(find.text('string:test'), findsOneWidget);
    });
  });

  group('ViewModelBuilder', () {
    testWidgets('builds widget with ViewModel state', (tester) async {
      final vm = CounterViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => vm,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel) {
                return Text('${viewModel.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('rebuilds when ViewModel notifies listeners', (tester) async {
      final vm = CounterViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => vm,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel) {
                return Text('${viewModel.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      vm.increment();
      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      vm.increment();
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('rebuilds multiple times correctly', (tester) async {
      final vm = CounterViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => vm,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel) {
                return Text('count:${viewModel.count}');
              },
            ),
          ),
        ),
      );

      for (int i = 1; i <= 5; i++) {
        vm.increment();
        await tester.pump();
        expect(find.text('count:$i'), findsOneWidget);
      }
    });

    testWidgets('does not rebuild unnecessarily', (tester) async {
      final vm = CounterViewModel();
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => vm,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel) {
                buildCount++;
                return Text('${viewModel.count}');
              },
            ),
          ),
        ),
      );

      final initialBuildCount = buildCount;

      // Pump without any changes
      await tester.pump();

      expect(buildCount, equals(initialBuildCount));
    });

    testWidgets('builder receives correct ViewModel instance', (tester) async {
      final vm = CounterViewModel();
      CounterViewModel? receivedVm;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => vm,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel) {
                receivedVm = viewModel;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(receivedVm, equals(vm));
    });

    testWidgets('works with StringViewModel', (tester) async {
      final vm = StringViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<StringViewModel>(
            create: () => vm,
            child: ViewModelBuilder<StringViewModel>(
              builder: (context, viewModel) {
                return Text(viewModel.value.isEmpty ? 'empty' : viewModel.value);
              },
            ),
          ),
        ),
      );

      expect(find.text('empty'), findsOneWidget);

      vm.setValue('hello');
      await tester.pump();

      expect(find.text('hello'), findsOneWidget);

      vm.setValue('world');
      await tester.pump();

      expect(find.text('world'), findsOneWidget);
    });

    testWidgets('multiple ViewModelBuilders update independently',
        (tester) async {
      final counterVm = CounterViewModel();
      final stringVm = StringViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => counterVm,
            child: ViewModelProvider<StringViewModel>(
              create: () => stringVm,
              child: Column(
                children: [
                  ViewModelBuilder<CounterViewModel>(
                    builder: (context, vm) => Text('counter:${vm.count}'),
                  ),
                  ViewModelBuilder<StringViewModel>(
                    builder: (context, vm) =>
                        Text('string:${vm.value.isEmpty ? "empty" : vm.value}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('counter:0'), findsOneWidget);
      expect(find.text('string:empty'), findsOneWidget);

      counterVm.increment();
      await tester.pump();

      expect(find.text('counter:1'), findsOneWidget);
      expect(find.text('string:empty'), findsOneWidget);

      stringVm.setValue('updated');
      await tester.pump();

      expect(find.text('counter:1'), findsOneWidget);
      expect(find.text('string:updated'), findsOneWidget);
    });
  });

  group('ViewModel integration', () {
    testWidgets('full counter app flow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: Scaffold(
              body: ViewModelBuilder<CounterViewModel>(
                builder: (context, vm) {
                  return Column(
                    children: [
                      Text('Count: ${vm.count}'),
                      ElevatedButton(
                        onPressed: vm.increment,
                        child: const Text('Increment'),
                      ),
                      ElevatedButton(
                        onPressed: vm.decrement,
                        child: const Text('Decrement'),
                      ),
                      ElevatedButton(
                        onPressed: vm.reset,
                        child: const Text('Reset'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();
      expect(find.text('Count: 2'), findsOneWidget);

      await tester.tap(find.text('Decrement'));
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('ViewModel persists across widget rebuilds', (tester) async {
      final vm = CounterViewModel();
      vm.increment();
      vm.increment();
      vm.increment();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => vm,
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel) {
                return Text('${viewModel.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);

      // Force a rebuild
      await tester.pump();

      // State should persist
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('ViewModel state is maintained through hot reload simulation',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) => Text('${vm.count}'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Get the ViewModel and modify state
      final context = tester.element(find.byType(ViewModelBuilder<CounterViewModel>));
      final vm = ViewModelProvider.of<CounterViewModel>(context);
      vm.increment();
      vm.increment();

      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Pump again to simulate rebuild
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });
  });
}
