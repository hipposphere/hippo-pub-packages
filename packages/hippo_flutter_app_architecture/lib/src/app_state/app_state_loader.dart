abstract class AppStateLoader<T> {
  Stream<T> loadAppState();

  T get initialAppState;
}
