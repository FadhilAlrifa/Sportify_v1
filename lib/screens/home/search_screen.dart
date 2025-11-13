import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/court_provider.dart';
import '../../widgets/court_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourtProvider>(context, listen: false).search('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<CourtProvider>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari lapangan atau lokasi'),
            onSubmitted: (v) => cp.search(v),
          ),
        ),
        if (cp.loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: ListView.builder(
              itemCount: cp.courts.length,
              itemBuilder: (ctx, i) => CourtCard(court: cp.courts[i]),
            ),
          )
      ],
    );
  }
}
