import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_viewmodel/flutter_viewmodel.dart';

class SimpleViewModel extends ViewModel {
  String _message = 'Hello';

  String get message => _message;

  void updateMessage(String newMessage) {
    _message = newMessage;
    notifyListeners();
  }
}

void main() {
  group('Widget integration tests', () {
    testWidgets('SimpleViewModel message updates UI correctly', (tester) async {
      final viewModel = SimpleViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewModelProvider<SimpleViewModel>(
              viewModel: viewModel,
              child: ViewModelBuilder<SimpleViewModel>(
                builder: (context, vm) {
                  return Column(
                    children: [
                      Text(vm.message),
                      ElevatedButton(
                        onPressed: () => vm.updateMessage('World'),
                        child: const Text('Update'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);

      await tester.tap(find.text('Update'));
      await tester.pump();

      expect(find.text('World'), findsOneWidget);
      expect(find.text('Hello'), findsNothing);
    });

    testWidgets('multiple ViewModelBuilders react to same ViewModel',
        (tester) async {
      final viewModel = SimpleViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewModelProvider<SimpleViewModel>(
              viewModel: viewModel,
              child: Column(
                children: [
                  ViewModelBuilder<SimpleViewModel>(
                    builder: (context, vm) => Text('A: ${vm.message}'),
                  ),
                  ViewModelBuilder<SimpleViewModel>(
                    builder: (context, vm) => Text('B: ${vm.message}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('A: Hello'), findsOneWidget);
      expect(find.text('B: Hello'), findsOneWidget);

      viewModel.updateMessage('Flutter');
      await tester.pump();

      expect(find.text('A: Flutter'), findsOneWidget);
      expect(find.text('B: Flutter'), findsOneWidget);
    });
  });
}
