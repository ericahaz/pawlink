part of pawlink_admin;

class MultiStreamBuilder extends StatelessWidget {
  final List<Stream> streams;
  final Widget Function(BuildContext context, List snapshots) builder;

  const MultiStreamBuilder({
    super.key,
    required this.streams,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (streams.isEmpty) {
      return builder(context, []);
    }

    return StreamBuilder(
      stream: streams.first,
      builder: (context, snapshot) {
        if (streams.length == 1) {
          return builder(context, [snapshot.data ?? []]);
        }

        return MultiStreamBuilder(
          streams: streams.sublist(1),
          builder: (context, rest) {
            return builder(context, [snapshot.data ?? [], ...rest]);
          },
        );
      },
    );
  }
}