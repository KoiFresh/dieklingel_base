import '/bloc/bloc_provider.dart';
import 'package:dieklingel_base/blocs/sign_view_bloc.dart';
import 'package:dieklingel_base/models/sign_options.dart';
import 'package:flutter/material.dart';

import 'components/sign.dart';

class SignView extends StatelessWidget {
  const SignView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<SignViewBloc>().options,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<SignOptions>> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<SignOptions> options = snapshot.data!;

        return ListView.builder(
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            return Sign(
              options: options[index],
            );
          },
        );
      },
    );
  }
}
