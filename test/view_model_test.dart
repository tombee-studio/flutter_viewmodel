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
  bool initialized = false;

  @override
  void init() {
    initialized = true;
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

class StringViewModel extends ViewModel {
  String _value = '';

  String get value => _value;

  void setValue(String val) {
    _value = val;
    notifyListeners();
  }
}

void main() {
  group('ViewModel', () {
    test('initial state is correct', () {
      final viewModel = CounterViewModel();
      expect(viewModel.count, 0);
    });

    test('increment updates count', () {
      final viewModel = CounterViewModel();
      viewModel.increment();
      expect(viewModel.count, 1);
    });

    test('decrement updates count', () {
      final viewModel = CounterViewModel();
      viewModel.decrement();
      expect(viewModel.count, -1);
    });

    test('multiple increments work correctly', () {
      final viewModel = CounterViewModel();
      viewModel.increment();
      viewModel.increment();
      viewModel.increment();
      expect(viewModel.count, 3);
    });

    test('reset sets count to zero', () {
      final viewModel = CounterViewModel();
      viewModel.increment();
      viewModel.increment();
      viewModel.reset();
      expect(viewModel.count, 0);
    });

    test('notifyListeners is called on state change', () {
      final viewModel = CounterViewModel();
      int notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

      viewModel.increment();
      expect(notificationCount, 1);

      viewModel.increment();
      expect(notificationCount, 2);

      viewModel.decrement();
      expect(notificationCount, 3);
    });

    test('dispose is called correctly', () {
      final viewModel = DisposableViewModel();
      expect(viewModel.disposed, false);
      viewModel.dispose();
      expect(viewModel.disposed, true);
    });

    test('init is called correctly', () {
      final viewModel = DisposableViewModel();
      expect(viewModel.initialized, false);
      viewModel.init();
      expect(viewModel.initialized, true);
    });

    test('ViewModel extends ChangeNotifier', () {
      final viewModel = CounterViewModel();
      expect(viewModel, isA<ChangeNotifier>());
    });

    test('listeners are removed after dispose', () {
      final viewModel = CounterViewModel();
      int notificationCount = 0;
      void listener() {
        notificationCount++;
      }

      viewModel.addListener(listener);
      viewModel.increment();
      expect(notificationCount, 1);

      viewModel.removeListener(listener);
      viewModel.increment();
      expect(notificationCount, 1);
    });

    test('StringViewModel updates value correctly', () {
      final viewModel = StringViewModel();
      expect(viewModel.value, '');

      viewModel.setValue('hello');
      expect(viewModel.value, 'hello');

      viewModel.setValue('world');
      expect(viewModel.value, 'world');
    });

    test('StringViewModel notifies listeners on change', () {
      final viewModel = StringViewModel();
      String? lastValue;
      viewModel.addListener(() {
        lastValue = viewModel.value;
      });

      viewModel.setValue('test');
      expect(lastValue, 'test');
    });
  });

  group('ViewModelProvider', () {
    testWidgets('provides ViewModel to subtree', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: Builder(
              builder: (context) {
                final vm = ViewModelProvider.of<CounterViewModel>(context);
                return Text('count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);
    });

    testWidgets('creates ViewModel only once', (WidgetTester tester) async {
      int createCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () {
              createCount++;
              return CounterViewModel();
            },
            child: Builder(
              builder: (context) {
                final vm = ViewModelProvider.of<CounterViewModel>(context);
                return Text('count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(createCount, 1);

      await tester.pump();
      expect(createCount, 1);
    });

    testWidgets('disposes ViewModel when removed from tree',
        (WidgetTester tester) async {
      final viewModel = DisposableViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<DisposableViewModel>(
            create: () => viewModel,
            child: const SizedBox(),
          ),
        ),
      );

      expect(viewModel.disposed, false);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(viewModel.disposed, true);
    });

    testWidgets('throws when no provider found in context',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => ViewModelProvider.of<CounterViewModel>(context),
                throwsA(anything),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('ViewModelBuilder', () {
    testWidgets('builds with initial ViewModel state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) {
                return Text('count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);
    });

    testWidgets('rebuilds when ViewModel state changes',
        (WidgetTester tester) async {
      late CounterViewModel viewModel;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () {
              viewModel = CounterViewModel();
              return viewModel;
            },
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) {
                return Text('count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);

      viewModel.increment();
      await tester.pump();

      expect(find.text('count: 1'), findsOneWidget);
    });

    testWidgets('rebuilds multiple times on multiple state changes',
        (WidgetTester tester) async {
      late CounterViewModel viewModel;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () {
              viewModel = CounterViewModel();
              return viewModel;
            },
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) {
                return Text('count: ${vm.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);

      viewModel.increment();
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);

      viewModel.increment();
      await tester.pump();
      expect(find.text('count: 2'), findsOneWidget);

      viewModel.decrement();
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);
    });

    testWidgets('provides correct ViewModel instance in builder',
        (WidgetTester tester) async {
      late CounterViewModel providedViewModel;
      late CounterViewModel builtViewModel;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () {
              providedViewModel = CounterViewModel();
              return providedViewModel;
            },
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, vm) {
                builtViewModel = vm;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(identical(providedViewModel, builtViewModel), true);
    });

    testWidgets('works with StringViewModel', (WidgetTester tester) async {
      late StringViewModel viewModel;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<StringViewModel>(
            create: () {
              viewModel = StringViewModel();
              return viewModel;
            },
            child: ViewModelBuilder<StringViewModel>(
              builder: (context, vm) {
                return Text('value: ${vm.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('value: '), findsOneWidget);

      viewModel.setValue('hello');
      await tester.pump();

      expect(find.text('value: hello'), findsOneWidget);
    });
  });

  group('Integration tests', () {
    testWidgets('full counter app integration test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewModelProvider<CounterViewModel>(
              create: () => CounterViewModel(),
              child: ViewModelBuilder<CounterViewModel>(
                builder: (context, vm) {
                  return Column(
                    children: [
                      Text('count: ${vm.count}'),
                      ElevatedButton(
                        onPressed: vm.increment,
                        child: const Text('increment'),
                      ),
                      ElevatedButton(
                        onPressed: vm.decrement,
                        child: const Text('decrement'),
                      ),
                      ElevatedButton(
                        onPressed: vm.reset,
                        child: const Text('reset'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);

      await tester.tap(find.text('increment'));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);

      await tester.tap(find.text('increment'));
      await tester.pump();
      expect(find.text('count: 2'), findsOneWidget);

      await tester.tap(find.text('decrement'));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);

      await tester.tap(find.text('reset'));
      await tester.pump();
      expect(find.text('count: 0'), findsOneWidget);
    });

    testWidgets('nested ViewModelProviders work independently',
        (WidgetTester tester) async {
      late CounterViewModel outerVm;
      late StringViewModel innerVm;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () {
              outerVm = CounterViewModel();
              return outerVm;
            },
            child: ViewModelProvider<StringViewModel>(
              create: () {
                innerVm = StringViewModel();
                return innerVm;
              },
              child: ViewModelBuilder<CounterViewModel>(
                builder: (context, counterVm) {
                  return ViewModelBuilder<StringViewModel>(
                    builder: (context, stringVm) {
                      return Column(
                        children: [
                          Text('count: ${counterVm.count}'),
                          Text('value: ${stringVm.value}'),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);
      expect(find.text('value: '), findsOneWidget);

      outerVm.increment();
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);
      expect(find.text('value: '), findsOneWidget);

      innerVm.setValue('hello');
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);
      expect(find.text('value: hello'), findsOneWidget);
    });
  });
}
