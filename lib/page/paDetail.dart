import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:payin_attachment/model/mdListPA.dart';
import '../../font/appColor.dart';
import '../../font/appFonts.dart';
import '../api/DbConnect.dart';
import '../util/dateformat.dart';

class AdvDetail extends StatefulWidget {
  const AdvDetail({super.key});

  @override
  State<AdvDetail> createState() => _AdvDetailState();
}

class _AdvDetailState extends State<AdvDetail> {
  String? dateSelected;
  String? detailSelected;

  List<ListPA> _paData = [];
  List<Details>? detailPA;
  bool _loading = false;

  @override
  void initState() {
    _dBListPA();

    super.initState();
  }

  Future<void> _dBListPA() async {
    await Dbconnect().getPA().then((onValue) {
      if(onValue != null) {
        setState(() {
          _paData = onValue;
          _loading = true;
        });
      }
      // print('data >> $_paData');
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("รายการบันทึกเงิน Pay Advance", style: TextStyle(fontFamily: AppFonts.pgVim, color: Colors.white, fontSize: width * .011)),
          ],
        ),
        backgroundColor: AppColors.pinkcm,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: width * .11,
            // height: height * .9,
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('วันที่', style: TextStyle(fontSize: width * .011, fontFamily: AppFonts.pgVim, color: Colors.black))
                ),
                _loading ? Expanded(
                  child: ListView.builder(
                    itemCount: _paData.length,
                    itemBuilder: (context, index) {
                      final day = _paData[index];
                      Color bgColor = day.docdate != dateSelected ? const Color.fromARGB(255, 252,228,236) : AppColors.darkPink; //const Color.fromARGB(255, 244, 143, 177)
                      Color textColor = day.docdate != dateSelected ? Colors.black : Colors.white; //const Color.fromARGB(255, 85, 4, 31)
          
                      return InkWell(
                        onTap: (){
                          setState(() {
                            dateSelected = day.docdate;
                            detailPA = day.details;
                            detailSelected = null;
                          });
                        },
                        child: Card(
                          color: bgColor,
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              dateformat(date: DateTime.parse(day.docdate!), type: 'dp'),
                              style: TextStyle(fontSize: width * .0085, fontFamily: AppFonts.pgVim, color: textColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ) : Center(child: LoadingAnimationWidget.staggeredDotsWave(color: AppColors.pinkcm, size: width * .02)),
              ],
            ),
          ),
          if(detailPA != null) Container(
            width: width * .6,
            // height: height * .9,
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('รายการเอกสารวันที่ ${dateformat(date: DateTime.parse(dateSelected!), type: 'dp')}', style: TextStyle(fontSize: width * .011, fontFamily: AppFonts.pgVim, color: Colors.black)),
                Expanded(
                  child: ListView.builder(
                    itemCount: detailPA!.length,
                    itemBuilder: (context, index) {
                      final data = detailPA![index];
                      double fSize = width * .0085;
                      Color bgColor = data.id != detailSelected ? const Color.fromARGB(255, 252,228,236) : AppColors.darkPink; //const Color.fromARGB(255, 244, 143, 177)
                      Color textColor = data.id != detailSelected ? Colors.black : Colors.white; //const Color.fromARGB(255, 85, 4, 31)
      
                      return InkWell(
                        onTap: (){
                          setState(() {
                            detailSelected = data.id;
                          });
                        },
                        child: Card(
                          color: bgColor,
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                      ),
                                      child: Text(
                                        data.trrunno ?? '',
                                        style: TextStyle(fontSize: fSize, fontFamily: AppFonts.traJanProBold, color: Colors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(width: width * .005),
                                    body('${data.extcode ?? ''} ${data.customerName ?? ''}', fSize, width * .25, AppFonts.pgVim, textColor)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    body(data.accname ?? '', fSize, width * .165, AppFonts.pgVim, textColor),
                                    body(data.refno ?? '', fSize, width * .045, AppFonts.pgVim, textColor),
                                    body(formatter.format(double.parse(data.amount ?? '0')), fSize, width * .05, AppFonts.traJanProBold, textColor, alignment: Alignment.centerRight)
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ),
              ],
            ),
          ),
          if(detailSelected != null) Expanded(
            child: Image.asset('assets/images/scb.jpg', fit: BoxFit.contain)
          )
        ],
      )
    );
  }

  Widget body(String value, double fSize, double box, String fontFamily, Color textColor, {Alignment alignment = Alignment.centerLeft}) {
    return Container(
      width: box,
      alignment: alignment,
      child: Text(value, style: TextStyle(fontSize: fSize, fontFamily:  fontFamily, color: textColor)),
    );
  }
}