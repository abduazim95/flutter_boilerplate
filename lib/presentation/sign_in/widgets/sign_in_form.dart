import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/application/auth/sign_in_form/sign_in_form_bloc.dart';

class SignInForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) {
        
      },
      builder: (context, state) {
        final SignInFormBloc signInFormBloc = context.read<SignInFormBloc>();
        return Form(
          autovalidate: state.showErrorMessages,
          child: ListView(
            children: [
              const Text(
                '📝',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 130
                )
              ),
              const SizedBox(height: 8,),
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  labelText: 'Email'
                ),
                autocorrect: false,
                onChanged: (value) => signInFormBloc.add(SignInFormEvent.emailChanged(value)),
                validator: (_) => signInFormBloc
                  .state
                  .emailAddress
                  .value.fold(
                  (l) => l.maybeMap(
                    invalidEmail: (_) => 'Invalid Email',
                    orElse: () => null
                  ),
                  (r) => null
                ),
              ),
              const SizedBox(height: 8,),
              TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Password'
                ),
                autocorrect: false,
                obscureText: true,
                onChanged: (value) => signInFormBloc.add(SignInFormEvent.passwordChanged(value)),
                validator: (_) => signInFormBloc
                  .state
                  .password
                  .value.fold(
                    (l) => l.maybeMap(
                      shortPassword: (_) => 'Invalid Password',
                      orElse: () => null
                    ),
                    (r) => null
                  ),
              ),
              const SizedBox(height: 8,),
              Row(children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      signInFormBloc.add(
                        const SignInFormEvent.signInWithEmailAndPassswordPressed()
                      );
                    },
                    child: const Text('SIGN IN')
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      signInFormBloc.add(
                        const SignInFormEvent.registerWithEmailAndPassswordPressed()
                      );
                    },
                    child: const Text('REGISTER')
                  ),
                )
              ],),
              ElevatedButton(
                onPressed: () {
                  signInFormBloc.add(
                    const SignInFormEvent.signInWithGooglePressed()
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue)
                ),
                child: const Text('SIGN IN WITH GOOGLE'),
              )
            ],
          ),
        );
      }
    );
  }
}