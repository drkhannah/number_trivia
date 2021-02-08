import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/use_case.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initialState should be Empty', () async {
    //assert
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setupMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
            () async {
          //arrange
          setupMockInputConverterSuccess();

          //act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
          await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

          //assert
          verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
        });

    test('should emit [Error] when the input is invalid', () async {
      //arrange
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));

      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));

      //assert
      final expected = [
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      expect(bloc.state, Empty());
      expectLater(
        bloc,
        emitsInOrder(expected),
      );
    });

    test('should get data from the concrete use case', () async {
      //arrange
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));

      //assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten succesfully',
            () async {
          //arrange
          setupMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Right(tNumberTrivia));

          //assert
          final expected = [
            Loading(),
            Loaded(trivia: tNumberTrivia),
          ];
          expect(bloc.state, Empty());
          expectLater(
            bloc,
            emitsInOrder(expected),
          );

          //act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        });

    test('should emit [Loading, Error] when getting data fails', () async {
      //arrange
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      //assert
      final expected = [
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expect(bloc.state, Empty());
      expectLater(
        bloc,
        emitsInOrder(expected),
      );

      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emit [Loading, Error] with proper message for the error when getting data fails',
            () async {
          //arrange
          setupMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));

          //assert
          final expected = [
            Loading(),
            Error(message: CACHE_FAILURE_MESSAGE),
          ];
          expect(bloc.state, Empty());
          expectLater(
            bloc,
            emitsInOrder(expected),
          );

          //act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        });
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test('should get data from the random use case', () async {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));

      //assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Loaded] when data is gotten succesfully',
            () async {
          //arrange
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Right(tNumberTrivia));

          //assert
          final expected = [
            Loading(),
            Loaded(trivia: tNumberTrivia),
          ];
          expect(bloc.state, Empty());
          expectLater(
            bloc,
            emitsInOrder(expected),
          );

          //act
          bloc.add(GetTriviaForRandomNumber());
        });

    test('should emit [Loading, Error] when getting data fails', () async {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      //assert
      final expected = [
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expect(bloc.state, Empty());
      expectLater(
        bloc,
        emitsInOrder(expected),
      );

      //act
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'should emit [Loading, Error] with proper message for the error when getting data fails',
            () async {
          //arrange
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));

          //assert
          final expected = [
            Loading(),
            Error(message: CACHE_FAILURE_MESSAGE),
          ];
          expect(bloc.state, Empty());
          expectLater(
            bloc,
            emitsInOrder(expected),
          );

          //act
          bloc.add(GetTriviaForRandomNumber());
        });
  });
}
