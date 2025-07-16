import 'package:flutter/material.dart';

class PriorityItems extends StatelessWidget {
  const PriorityItems({super.key});

  @override
  Widget build(BuildContext context) {

    String? selectedPriority = "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Priority: None
        MaterialButton(
          padding: EdgeInsets.all(8),
          height: 20,
          child: Row(
            children: [
              Icon(Icons.flag_outlined, color: Colors.red, size: 30,),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("High Priority", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400,),),
              ),
            ],
          ),
          onPressed: () {
            selectedPriority = "High";
            Navigator.pop(context, selectedPriority);
          },
        ),
        //Priority: Low
        MaterialButton(
          padding: EdgeInsets.all(8),
          height: 20,
          child: Row(
            children: [
              Icon(Icons.flag_outlined, color: Colors.amber, size: 30,),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("Medium Priority", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400,),),
              ),
            ],
          ),
          onPressed: () {
            selectedPriority = "Medium";
            Navigator.pop(context, selectedPriority);
          },
        ),
        //Priority: Medium
        MaterialButton(
          padding: EdgeInsets.all(8),
          height: 20,
          child: Row(
            children: [
              Icon(Icons.flag_outlined, color: Colors.lightBlue, size: 30,),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("Low Priority", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400,),),
              ),
            ],
          ),
          onPressed: () {
            selectedPriority = "Low";
            Navigator.pop(context, selectedPriority);
          },
        ),
        //Priority: High
        MaterialButton(
          padding: EdgeInsets.all(8),
          height: 20,
          child: Row(
            children: [
              Icon(Icons.flag_outlined, color: Colors.grey, size: 30,),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("No Priority", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400,),),
              ),
            ],
          ),
          onPressed: () {
            selectedPriority = "None";
            Navigator.pop(context, selectedPriority);
          },
        )
      ],
    );
  }
}