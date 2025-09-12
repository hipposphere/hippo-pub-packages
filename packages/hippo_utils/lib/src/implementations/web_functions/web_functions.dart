import 'impl/stub.dart' if (dart.library.js_interop) 'impl/web.dart' as impl;
import 'models/web_functions_abstraction.dart';

WebFunctionsAbstraction get webFunctions => impl.WebFunctionsImpl();
