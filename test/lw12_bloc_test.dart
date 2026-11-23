import 'package:flutter_test/flutter_test.dart';
// NOTE: "sole_app" must match the `name:` in your pubspec.yaml
import 'package:sole_app/lw12/auth/auth_cubit.dart';
import 'package:sole_app/lw12/auth/auth_state.dart';
import 'package:sole_app/lw12/cart/cart_bloc.dart';
import 'package:sole_app/lw12/cart/cart_event.dart';
import 'package:sole_app/lw12/cart/cart_state.dart';
import 'package:sole_app/models/product.dart';

Product _p(String id, double price) => Product(
      id: id,
      name: 'Shoe $id',
      brand: 'Brand',
      category: 'Sport',
      price: price,
      rating: 4,
      reviews: 1,
      tags: const [],
      sizes: const [42],
      description: '',
      imageUrl: '',
    );

/// Runs [action] and returns every state emitted meanwhile.
Future<List<S>> _collect<S>(
    Stream<S> stream, Future<void> Function() action) async {
  final states = <S>[];
  final sub = stream.listen(states.add);
  await action();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

void main() {
  group('AuthCubit', () {
    test('starts with AuthInitial', () {
      final c = AuthCubit(delay: Duration.zero);
      expect(c.state, const AuthInitial());
      c.close();
    });

    test('valid credentials: Loading -> Success', () async {
      final c = AuthCubit(delay: Duration.zero);
      final states = await _collect(
          c.stream, () => c.login('student@narxoz.kz', '123456'));
      expect(states, [
        const AuthLoading(),
        const AuthSuccess(username: 'Student', email: 'student@narxoz.kz'),
      ]);
      await c.close();
    });

    test('email is trimmed and case-insensitive', () async {
      final c = AuthCubit(delay: Duration.zero);
      await c.login('  Student@Narxoz.KZ ', '123456');
      expect(c.state, isA<AuthSuccess>());
      await c.close();
    });

    test('wrong password: Loading -> Error', () async {
      final c = AuthCubit(delay: Duration.zero);
      final states = await _collect(
          c.stream, () => c.login('student@narxoz.kz', 'wrong'));
      expect(states,
          [const AuthLoading(), const AuthError('Invalid email or password')]);
      await c.close();
    });

    test('malformed email gives a validation error', () async {
      final c = AuthCubit(delay: Duration.zero);
      await c.login('not-an-email', '123456');
      expect(c.state, const AuthError('Enter a valid email address'));
      await c.close();
    });

    test('empty fields give an error', () async {
      final c = AuthCubit(delay: Duration.zero);
      await c.login('', '');
      expect(c.state, const AuthError('Email and password are required'));
      await c.close();
    });

    test('same error twice still emits (Loading is in between)', () async {
      final c = AuthCubit(delay: Duration.zero);
      final states = await _collect(c.stream, () async {
        await c.login('a@b.kz', 'x');
        await c.login('a@b.kz', 'x');
      });
      expect(states.whereType<AuthError>().length, 2);
      await c.close();
    });

    test('logout returns to AuthInitial', () async {
      final c = AuthCubit(delay: Duration.zero);
      await c.login('student@narxoz.kz', '123456');
      c.logout();
      expect(c.state, const AuthInitial());
      await c.close();
    });

    test('Equatable: equal values are equal states', () {
      expect(const AuthError('x'), const AuthError('x'));
      expect(const AuthError('x') == const AuthError('y'), false);
      expect(const AuthSuccess(username: 'a', email: 'b'),
          const AuthSuccess(username: 'a', email: 'b'));
    });
  });

  group('CartBloc', () {
    late CartBloc bloc;
    setUp(() => bloc = CartBloc());
    tearDown(() => bloc.close());

    test('initial state is empty', () {
      expect(bloc.state, const CartState());
      expect(bloc.state.count, 0);
      expect(bloc.state.totalPrice, 0);
    });

    test('AddProductEvent adds a line', () async {
      bloc.add(AddProductEvent(_p('a', 10)));
      await bloc.stream.first;
      expect(bloc.state.items.length, 1);
      expect(bloc.state.count, 1);
      expect(bloc.state.totalPrice, 10);
    });

    test('adding the same product again increases quantity', () async {
      bloc
        ..add(AddProductEvent(_p('a', 10)))
        ..add(AddProductEvent(_p('a', 10)));
      await bloc.stream.take(2).toList();
      expect(bloc.state.items.length, 1);
      expect(bloc.state.items.first.quantity, 2);
      expect(bloc.state.count, 2);
      expect(bloc.state.totalPrice, 20);
    });

    test('total and count with several products', () async {
      bloc
        ..add(AddProductEvent(_p('a', 10.5)))
        ..add(AddProductEvent(_p('b', 4.5)))
        ..add(AddProductEvent(_p('a', 10.5)));
      await bloc.stream.take(3).toList();
      expect(bloc.state.count, 3);
      expect(bloc.state.totalPrice, closeTo(25.5, 1e-9));
      expect(bloc.state.quantityOf('a'), 2);
      expect(bloc.state.quantityOf('zzz'), 0);
    });

    test('RemoveProductEvent removes the whole line', () async {
      bloc
        ..add(AddProductEvent(_p('a', 10)))
        ..add(AddProductEvent(_p('a', 10)))
        ..add(AddProductEvent(_p('b', 5)))
        ..add(const RemoveProductEvent('a'));
      await bloc.stream.take(4).toList();
      expect(bloc.state.items.map((l) => l.product.id), ['b']);
      expect(bloc.state.count, 1);
      expect(bloc.state.totalPrice, 5);
    });

    test('ClearCartEvent empties the cart', () async {
      bloc
        ..add(AddProductEvent(_p('a', 10)))
        ..add(const ClearCartEvent());
      await bloc.stream.take(2).toList();
      expect(bloc.state, const CartState());
    });

    test('emits the expected sequence of states', () async {
      final states = await _collect(bloc.stream, () async {
        bloc
          ..add(AddProductEvent(_p('a', 10)))
          ..add(const RemoveProductEvent('a'));
      });
      expect(states.map((s) => s.count), [1, 0]);
    });
  });
}
