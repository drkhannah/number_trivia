import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key key,
  }) : super(key: key);

  @override
  _TriviaControlsState createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputString;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a Number',
          ),
          onChanged: (value) {
            inputString = value;
          },
          onSubmitted: (_) {
            addConcrete();
          },
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: RaisedButton(
                child: Text('Search'),
                color: Theme.of(context).accentColor,
                textTheme: ButtonTextTheme.primary,
                onPressed: addConcrete,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: RaisedButton(
                child: Text('Get Random Trivia'),
                onPressed: addRandom,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void addConcrete() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForConcreteNumber(inputString));
  }

  void addRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
  }
}
