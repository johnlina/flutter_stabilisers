# Flutter-Stabilisers

Dealing with errors is a daily - sometimes hourly - task of almost every developer. A task usually followed by a long time looking for help on StackOverflow or GitHub.


`Flutter-Stabilisers` automatically looks for solutions to your errors on **StackOverflow** and **GitHub Issues**, saving your precious time for those really hard-to-solve bugs.

## Getting started

Add the following dependency to `pubspec.yaml`:

```yaml
dependencies:
  ...
  flutter_stabilisers: "^0.0.1"
```

In your `main.dart` add the following import:

```dart
import 'package:flutter_stabilisers/flutter_stabilisers.dart';
```

Call `Stabilisers.config()` before running your app

```dart
void main() {

  Stabilisers.config();

  runApp(MyApp());

}
```

And that's all! Now all your error messages will be automatically searched on **StackOverflow** and **GitHub Issues**.

## Checking the results

You can check the results at the `console` of your IDE.

The error stack will be suppressed by default. If you want to view the full error stack on your console along with the search results you can set the flag on the `config()` method call.

```dart
void main() {

  Stabilisers.config(suppressStack: false);

  runApp(MyApp());

}
```
