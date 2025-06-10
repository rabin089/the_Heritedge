import 'package:flutter/material.dart';
import 'package:the_heritedge/Common/Screens/heritage.list.page.dart';
import 'package:the_heritedge/Common/widgets/filter.section.widget.dart';

class SuggestionHeaderWidget extends StatelessWidget {
  final String title;
  const SuggestionHeaderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Row(
            children: [
              TextButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HeritageListPage())
                  );
                },
                child: Text(

                  "View All",
                  style: TextStyle(fontSize: 12,
                      color: Colors.black
                  )
              ),
              ),
              // IconButton(
              //     icon: const Icon(Icons.filter_list),
              //     onPressed: () {
              //       showDialog(
              //         context: context,
              //         builder: (context) => FilterSectionWidget(),
              //       );
              //     }
              // )
            ],
          )
        ],
      ),
    );
  }
}
