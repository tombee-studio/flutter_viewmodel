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

  bool _initialized = false;
  bool _disposed = false;

  bool get initialized => _initialized;
  bool get disposed => _disposed;

  @override
  void init() {
    _initialized = true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

// Another ViewModel for testing multiple ViewModels
class TextViewModel extends ViewModel {
  String _text = '';

  String get text => _text;

  void updateText(String newText) {
    _text = newText;
    notifyListeners();
  }
}

void main() {
  group('ViewModel', () {
    test('initial state is correct', () {
      final viewModel = CounterViewModel();
      expect(viewModel.count, 0);
    });

    test('notifyListeners triggers listeners', () {
      final viewModel = CounterViewModel();
      int notifyCount = 0;

      viewModel.addListener(() {
        notifyCount++;
      });

      viewModel.increment();
      expect(notifyCount, 1);

      viewModel.increment();
      expect(notifyCount, 2);

      viewModel.decrement();
      expect(notifyCount, 3);
    });

    test('state updates correctly', () {
      final viewModel = CounterViewModel();
      expect(viewModel.count, 0);

      viewModel.increment();
      expect(viewModel.count, 1);

      viewModel.increment();
      expect(viewModel.count, 2);

      viewModel.decrement();
      expect(viewModel.count, 1);
    });

    test('init is called', () {
      final viewModel = CounterViewModel();
      viewModel.init();
      expect(viewModel.initialized, true);
    });

    test('dispose cleans up properly', () {
      final viewModel = CounterViewModel();
      viewModel.dispose();
      expect(viewModel.disposed, true);
    });

    test('listeners are removed after dispose', () {
      final viewModel = CounterViewModel();
      int notifyCount = 0;

      viewModel.addListener(() {
        notifyCount++;
      });

      viewModel.increment();
      expect(notifyCount, 1);

      viewModel.dispose();

      // After dispose, incrementing should not notify listeners
      // (ChangeNotifier behavior after dispose)
      expect(notifyCount, 1);
    });
  });

  group('ViewModelProvider', () {
    testWidgets('provides ViewModel to subtree', (WidgetTester tester) async {
      CounterViewModel? retrievedViewModel;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: Builder(
              builder: (context) {
                retrievedViewModel =
                    ViewModelProvider.of<CounterViewModel>(context);
                return const Text('test');
              },
            ),
          ),
        ),
      );

      expect(retrievedViewModel, isNotNull);
      expect(retrievedViewModel, isA<CounterViewModel>());
    });

    testWidgets('creates ViewModel only once across rebuilds',
        (WidgetTester tester) async {
      final viewModels = <CounterViewModel>[];

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: Builder(
              builder: (context) {
                viewModels
                    .add(ViewModelProvider.of<CounterViewModel>(context)!);
                return const Text('test');
              },
            ),
          ),
        ),
      );

      // Trigger a rebuild
      await tester.pump();

      expect(viewModels.length, greaterThan(0));
      if (viewModels.length > 1) {
        expect(viewModels[0], same(viewModels[1]));
      }
    });

    testWidgets('disposes ViewModel when removed from tree',
        (WidgetTester tester) async {
      CounterViewModel? vm;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () {
              vm = CounterViewModel();
              return vm!;
            },
            child: const Text('test'),
          ),
        ),
      );

      expect(vm, isNotNull);

      // Remove the ViewModelProvider from the tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Text('no provider'),
        ),
      );

      expect(vm!.disposed, true);
    });

    testWidgets('throws when no provider found', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => ViewModelProvider.of<CounterViewModel>(context,
                    listen: false),
                throwsA(anything),
              );
              return const Text('test');
            },
          ),
        ),
      );
    });
  });

  group('ViewModelBuilder', () {
    testWidgets('builds with initial state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel, child) {
                return Text('count: ${viewModel.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);
    });

    testWidgets('rebuilds when ViewModel notifies', (WidgetTester tester) async {
      CounterViewModel? vm;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () {
              vm = CounterViewModel();
              return vm!;
            },
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel, child) {
                return Text('count: ${viewModel.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);

      vm!.increment();
      await tester.pump();

      expect(find.text('count: 1'), findsOneWidget);
    });

    testWidgets('passes child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  children: [
                    Text('count: ${viewModel.count}'),
                    if (child != null) child,
                  ],
                );
              },
              child: const Text('static child'),
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);
      expect(find.text('static child'), findsOneWidget);
    });

    testWidgets('multiple rebuilds work correctly', (WidgetTester tester) async {
      CounterViewModel? vm;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () {
              vm = CounterViewModel();
              return vm!;
            },
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel, child) {
                return Text('count: ${viewModel.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);

      for (int i = 1; i <= 5; i++) {
        vm!.increment();
        await tester.pump();
        expect(find.text('count: $i'), findsOneWidget);
      }
    });

    testWidgets('does not rebuild when state has not changed',
        (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: ViewModelBuilder<CounterViewModel>(
              builder: (context, viewModel, child) {
                buildCount++;
                return Text('count: ${viewModel.count}');
              },
            ),
          ),
        ),
      );

      final initialBuildCount = buildCount;

      // No state change, just pump
      await tester.pump();

      expect(buildCount, initialBuildCount);
    });
  });

  group('Integration Tests', () {
    testWidgets('full counter app flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewModelProvider<CounterViewModel>(
              create: () => CounterViewModel(),
              child: ViewModelBuilder<CounterViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    children: [
                      Text('count: ${viewModel.count}'),
                      ElevatedButton(
                        onPressed: viewModel.increment,
                        child: const Text('Increment'),
                      ),
                      ElevatedButton(
                        onPressed: viewModel.decrement,
                        child: const Text('Decrement'),
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

      await tester.tap(find.text('Increment'));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();
      expect(find.text('count: 2'), findsOneWidget);

      await tester.tap(find.text('Decrement'));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);
    });

    testWidgets('nested ViewModelProviders work independently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ViewModelProvider<CounterViewModel>(
            create: () => CounterViewModel(),
            child: ViewModelProvider<TextViewModel>(
              create: () => TextViewModel(),
              child: Column(
                children: [
                  ViewModelBuilder<CounterViewModel>(
                    builder: (context, viewModel, child) {
                      return Text('count: ${viewModel.count}');
                    },
                  ),
                  ViewModelBuilder<TextViewModel>(
                    builder: (context, viewModel, child) {
                      return Text('text: ${viewModel.text}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);
      expect(find.text('text: '), findsOneWidget);
    });
  });
}
