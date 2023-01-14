import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:number_to_character/number_to_character.dart';
import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';

class pdf {
  static Future<void> doIt(BuildContext ctx, String name, String add,
      final itemlist, bool isP, int InvoiceNo) async {
    final img = await networkImage(
        'https://scontent.fdac27-2.fna.fbcdn.net/v/t1.15752-9/318631431_1197338447576173_6351736879351345471_n.jpg?stp=cp0_dst-jpg_e15_fr_q65&_nc_cat=103&ccb=1-7&_nc_sid=58c789&efg=eyJpIjoiYiJ9&_nc_eui2=AeEoQpyeFOtbxx7OLztdARjRX_CaRM_9okhf8JpEz_2iSGU7pxQXMGEnaKA-yWD3JyQ5MRB3mDBqVp71qvPaUFIh&_nc_ohc=RL7Z5HwKmXoAX-Gyvyi&_nc_ht=scontent.fdac27-2.fna&oh=03_AdQTQd4n3tqwWiko7evU1r57--I8iS7U7XvKkR9sDWugrA&oe=63DFF44E');

    var converter = NumberToCharacterConverter('en');
    String x = converter.convertDouble(126.75);

    print('printng x $x');
    print('printng Lengt is ${itemlist.length}');
    final pdf = pw.Document();
    //final font = await PdfGoogleFonts.nunitoExtraLight();
    // final itemlist = [
    //   {
    //     'name': 'Apedom',
    //     'type': 'Syrup',
    //     'pack': '50Pcs',
    //     'price': '220',
    //     'quantity': '10',
    //     'bonus': '0'
    //   },
    //   {
    //     'name': 'Cipro',
    //     'type': 'Capsul',
    //     'pack': '50Pcs',
    //     'price': '140',
    //     'quantity': '10',
    //     'bonus': '0'
    //   },
    //   {
    //     'name': 'MultiVita',
    //     'type': 'Syrup',
    //     'pack': '12ml',
    //     'price': '22',
    //     'quantity': '10',
    //     'bonus': '0'
    //   },
    //   {
    //     'name': 'HK-20',
    //     'type': 'Capsul',
    //     'pack': '80Pcs',
    //     'price': '69',
    //     'quantity': '10',
    //     'bonus': '0'
    //   },
    // ];

    double totalSum() {
      double x = 0;
      itemlist.forEach((element) {
        x += double.parse(element['price'].toString()) *
            double.parse(element['quantity'].toString());
      });
      return x;
    }

    double Netpay() {
      double x = (totalSum() + (totalSum() * .15));
      // return double.parse(x.toStringAsFixed(2));
      return x;
    }

    double findh() {
      double x = 490;
      x += itemlist.length * 18;
      print('returning $x');
      return x + 200;
    }

    final ttf = await fontFromAssetBundle('fonts/Cambria.ttf');
    final ttfB = await fontFromAssetBundle('fonts/cambriab.ttf');
    pdf.addPage(pw.Page(
        margin: pw.EdgeInsets.fromLTRB(20, 0, 20, 20),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
              height: findh(),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                width: 0.4,
                color: PdfColors.grey,
              )),
              child: pw.Column(children: [
                pw.Container(
                    child: pw.Column(children: [
                      pw.Container(
                          width: double.infinity,
                          height: 17,
                          alignment: pw.Alignment.center,
                          color: PdfColors.grey400,
                          child: pw.Text('INVOICE',
                              style: pw.TextStyle(
                                  font: ttf, fontWeight: pw.FontWeight.bold))),
                      pw.Text('Apollo Pharmaceutical Lab. LTD.',
                          style: pw.TextStyle(
                            font: ttfB,
                            fontSize: 22,
                          )),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text(
                        'Central Sales Depo : Plot # 11, Block # Ka, Main Road-1, Section # 6, Mirpur, Dhaka 1216, Bangladesh',
                        style: pw.TextStyle(
                            font: ttfB,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10),
                      ),
                      pw.Text(
                        'Tel:- +88 02 9030747, 9001794, 9025719, Fax:- +88 02 900 713',
                        style: pw.TextStyle(
                            font: ttfB,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10),
                      ),
                      pw.Text(
                        'Mobile:- 01711-697995',
                        style: pw.TextStyle(
                            font: ttfB,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10),
                      ),
                    ]),
                    height: 85,
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 0.4,
                        color: PdfColors.grey,
                      ),
                    )),
                pw.SizedBox(
                  height: 20,
                ),
                pw.Stack(alignment: pw.Alignment.center, children: [
                  pw.Divider(color: PdfColors.grey),
                  pw.DecoratedBox(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    child: pw.Text(' Invoice Details ',
                        style: pw.TextStyle(
                            font: ttfB,
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  // pw.Text('Invoice Details',
                  //    )
                ]),
                pw.SizedBox(
                  height: 5,
                ),
                pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                      width: 0.4,
                      color: PdfColors.cyan,
                    )),
                    padding: pw.EdgeInsets.fromLTRB(18, 10, 18, 15),
                    width: 530,
                    child: pw.Column(children: [
                      pw.Table(
                          columnWidths: {
                            0: pw.FixedColumnWidth(70),
                            1: pw.FixedColumnWidth(100),
                            2: pw.FixedColumnWidth(60),
                          },
                          border: pw.TableBorder.all(
                            width: 0.4,
                            color: PdfColors.grey,
                          ),
                          children: [
                            pw.TableRow(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  'Customer Name',
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  name,
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  'Invoice No.',
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  'H${InvoiceNo}',
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  'Customer Address',
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  add,
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  'Sales Date',
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  DateFormat.yMMMd().format(DateTime.now()),
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  'Area Name',
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  'Habiganj',
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  'TRT Name',
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(
                                  'Habiganj',
                                  style: pw.TextStyle(font: ttf, fontSize: 10),
                                ),
                              ),
                            ]),
                          ]),
                      pw.SizedBox(height: 25),
                      pw.Table(
                          defaultVerticalAlignment:
                              pw.TableCellVerticalAlignment.middle,
                          columnWidths: {
                            0: pw.FixedColumnWidth(10),
                            1: pw.FixedColumnWidth(52),
                            2: pw.FixedColumnWidth(33), //add
                            3: pw.FixedColumnWidth(25),
                            4: pw.FixedColumnWidth(25),
                            5: pw.FixedColumnWidth(26),
                            6: pw.FixedColumnWidth(20),
                            7: pw.FixedColumnWidth(32),
                          },
                          border: pw.TableBorder.all(
                            width: 0.4,
                            color: PdfColors.grey,
                          ),
                          children: [
                            pw.TableRow(children: [
                              pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(vertical: 3),
                                  child: pw.Text('SL',
                                      style: pw.TextStyle(
                                          font: ttfB,
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center)),
                              pw.Padding(
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Text('Product Name',
                                      style: pw.TextStyle(
                                          font: ttfB,
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center)),
                              pw.Padding(
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Text('Type',
                                      style: pw.TextStyle(
                                          font: ttfB,
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center)),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text('Pack Size',
                                    style: pw.TextStyle(
                                        font: ttfB,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold),
                                    textAlign: pw.TextAlign.center),
                              ),
                              pw.Padding(
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Text('Unit\nPrice',
                                      style: pw.TextStyle(
                                          font: ttfB,
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center)),
                              pw.Padding(
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Text('Quantity',
                                      style: pw.TextStyle(
                                          font: ttfB,
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center)),
                              pw.Padding(
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Text('Bonus',
                                      style: pw.TextStyle(
                                          font: ttfB,
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center)),
                              pw.Padding(
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Text('Total',
                                      style: pw.TextStyle(
                                          font: ttfB,
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center)),
                            ])
                          ]),
                      pw.ListView.builder(
                          itemBuilder: (context, index) {
                            return pw.Table(
                                columnWidths: {
                                  0: pw.FixedColumnWidth(10),
                                  1: pw.FixedColumnWidth(52),
                                  2: pw.FixedColumnWidth(33), //add
                                  3: pw.FixedColumnWidth(25),
                                  4: pw.FixedColumnWidth(25),
                                  5: pw.FixedColumnWidth(26),
                                  6: pw.FixedColumnWidth(20),
                                  7: pw.FixedColumnWidth(32),
                                },
                                border: pw.TableBorder.all(
                                  width: 0.4,
                                  color: PdfColors.grey,
                                ),
                                children: [
                                  pw.TableRow(children: [
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text((index + 1).toString(),
                                            textAlign: pw.TextAlign.center)),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          itemlist[index]['name'].toString(),
                                          style: pw.TextStyle(
                                              font: ttf, fontSize: 11)),
                                    ),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text(
                                            itemlist[index]['type'].toString(),
                                            style: pw.TextStyle(
                                                font: ttf, fontSize: 11))),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text(
                                            itemlist[index]['pack'].toString(),
                                            style: pw.TextStyle(
                                                font: ttf, fontSize: 11))),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text(
                                            itemlist[index]['price'].toString(),
                                            style: pw.TextStyle(
                                                font: ttf, fontSize: 11),
                                            textAlign: pw.TextAlign.center)),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text(
                                            itemlist[index]['quantity']
                                                .toString(),
                                            style: pw.TextStyle(
                                                font: ttf, fontSize: 11),
                                            textAlign: pw.TextAlign.center)),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text(
                                            itemlist[index]['bonus'].toString(),
                                            style: pw.TextStyle(
                                                font: ttf, fontSize: 11),
                                            textAlign: pw.TextAlign.center)),
                                    pw.Padding(
                                        padding:
                                            pw.EdgeInsets.fromLTRB(3, 3, 10, 3),
                                        child: pw.Text(
                                            '${(double.parse(itemlist[index]['price'].toString()) * double.parse(itemlist[index]['quantity'].toString())).toStringAsFixed(2)}',
                                            style: pw.TextStyle(
                                                font: ttf, fontSize: 11),
                                            textAlign: pw.TextAlign.right)),
                                  ])
                                ]);
                          },
                          itemCount: itemlist.length),
                      pw.ListView.builder(
                          itemBuilder: (context, index) {
                            return pw.Table(
                                columnWidths: {
                                  0: pw.FixedColumnWidth(10),
                                  1: pw.FixedColumnWidth(52),
                                  2: pw.FixedColumnWidth(33), //add
                                  3: pw.FixedColumnWidth(25),
                                  4: pw.FixedColumnWidth(25),
                                  5: pw.FixedColumnWidth(26),
                                  6: pw.FixedColumnWidth(20),
                                  7: pw.FixedColumnWidth(32),
                                },
                                border: pw.TableBorder.all(
                                  width: 0.4,
                                  color: PdfColors.grey,
                                ),
                                children: [
                                  pw.TableRow(children: [
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text('')),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text('')),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text('')),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text('')),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text('')),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text('')),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.all(3),
                                        child: pw.Text('')),
                                    pw.Padding(
                                      padding:
                                          pw.EdgeInsets.fromLTRB(3, 3, 10, 3),
                                      child: pw.Text('-',
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ])
                                ]);
                          },
                          itemCount: 2),
                      pw.Table(
                        columnWidths: {
                          0: pw.FixedColumnWidth(191),
                          1: pw.FixedColumnWidth(32),
                        },
                        border: pw.TableBorder.all(
                          width: 0.4,
                          color: PdfColors.grey,
                        ),
                        children: [
                          pw.TableRow(children: [
                            pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text('Total Trade Price  ',
                                    style:
                                        pw.TextStyle(font: ttf, fontSize: 11),
                                    textAlign: pw.TextAlign.right)),
                            pw.Padding(
                              padding: pw.EdgeInsets.fromLTRB(3, 3, 10, 3),
                              child: pw.Text(totalSum().toStringAsFixed(2),
                                  style: pw.TextStyle(font: ttf, fontSize: 11),
                                  textAlign: pw.TextAlign.right),
                            ),
                          ])
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          0: pw.FixedColumnWidth(191),
                          1: pw.FixedColumnWidth(32),
                        },
                        border: pw.TableBorder.all(
                          width: 0.4,
                          color: PdfColors.grey,
                        ),
                        children: [
                          pw.TableRow(children: [
                            pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text('Add Vat (15%)  ',
                                    style:
                                        pw.TextStyle(font: ttf, fontSize: 11),
                                    textAlign: pw.TextAlign.right)),
                            pw.Padding(
                              padding: pw.EdgeInsets.fromLTRB(3, 3, 10, 3),
                              child: pw.Text(
                                  '${(totalSum() * .15).toStringAsFixed(2)}',
                                  style: pw.TextStyle(font: ttf, fontSize: 11),
                                  textAlign: pw.TextAlign.right),
                            ),
                          ])
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          0: pw.FixedColumnWidth(191),
                          1: pw.FixedColumnWidth(32),
                        },
                        border: pw.TableBorder.all(
                          width: 0.4,
                          color: PdfColors.grey,
                        ),
                        children: [
                          pw.TableRow(children: [
                            pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text('        Net Payable  ',
                                    style:
                                        pw.TextStyle(font: ttf, fontSize: 11),
                                    textAlign: pw.TextAlign.right)),
                            pw.Padding(
                              padding: pw.EdgeInsets.fromLTRB(3, 3, 10, 3),
                              child: pw.Text('${Netpay().toStringAsFixed(2)}',
                                  style: pw.TextStyle(font: ttf, fontSize: 11),
                                  textAlign: pw.TextAlign.right),
                            ),
                          ])
                        ],
                      ),
                      pw.Table(
                        defaultVerticalAlignment:
                            pw.TableCellVerticalAlignment.middle,
                        columnWidths: {
                          0: pw.FixedColumnWidth(30),
                          1: pw.FixedColumnWidth(70),
                        },
                        border: pw.TableBorder.all(
                          width: 0.4,
                          color: PdfColors.grey,
                        ),
                        children: [
                          pw.TableRow(children: [
                            pw.Padding(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text('Chargeable Amount(in \n words)',
                                    style:
                                        pw.TextStyle(font: ttf, fontSize: 11),
                                    textAlign: pw.TextAlign.center)),
                            pw.Padding(
                              padding: pw.EdgeInsets.fromLTRB(7, 3, 3, 3),
                              child: pw.Text(
                                  '${converter.convertDouble(double.parse(Netpay().toStringAsFixed(2)))} Only',
                                  style: pw.TextStyle(font: ttf, fontSize: 11),
                                  textAlign: pw.TextAlign.left),
                            ),
                          ])
                        ],
                      ),
                      pw.SizedBox(height: 20),
                      pw.Table(
                        columnWidths: {
                          0: pw.FixedColumnWidth(10),
                          1: pw.FixedColumnWidth(10),
                          2: pw.FixedColumnWidth(10),
                        },
                        border: pw.TableBorder.all(
                          width: 0.4,
                          color: PdfColors.grey,
                        ),
                        children: [
                          pw.TableRow(children: [
                            pw.Container(height: 25),
                            pw.Container(),
                            pw.Center(
                              child: pw.Container(
                                height: 25,
                                width: double.infinity,
                                child: pw.Image(img),
                              ),
                            ),
                          ]),
                          pw.TableRow(children: [
                            pw.Container(),
                            pw.Container(),
                            pw.Container(),
                          ]),
                        ],
                      ),
                      pw.Table(
                        //  border: pw.TableBorder.symmetric(
                        //       color: Colors.grey[600],
                        //       //style: BorderStyle.solid,
                        //       width: 0.5,
                        //     ),
                        defaultVerticalAlignment:
                            pw.TableCellVerticalAlignment.middle,
                        columnWidths: {
                          0: pw.FixedColumnWidth(10),
                          1: pw.FixedColumnWidth(10),
                          2: pw.FixedColumnWidth(10),
                        },
                        border: pw.TableBorder.all(
                          width: 0.4,
                          color: PdfColors.grey,
                        ),
                        children: [
                          pw.TableRow(children: [
                            pw.Container(
                                alignment: pw.Alignment.center,
                                height: 50,
                                child: pw.Text(
                                    'Signature Of Customer\n(Received the above Goods in good\ncondition)',
                                    style: pw.TextStyle(font: ttf, fontSize: 9),
                                    textAlign: pw.TextAlign.center)),
                            pw.Container(
                                alignment: pw.Alignment.center,
                                height: 50,
                                child: pw.Text(
                                    'Signature of Verified by\n(On behalf of Apollo Pharmaceutical\nLab. Ltd.)',
                                    style: pw.TextStyle(font: ttf, fontSize: 9),
                                    textAlign: pw.TextAlign.center)),
                            pw.Container(
                                alignment: pw.Alignment.center,
                                height: 50,
                                child: pw.Text(
                                    'Signature of Sales Person\n(On behalf of Apollo Pharmaceutical\nLab. Ltd',
                                    style: pw.TextStyle(font: ttf, fontSize: 9),
                                    textAlign: pw.TextAlign.center)),
                          ]),
                          pw.TableRow(children: [
                            pw.Container(),
                            pw.Container(),
                            pw.Container(),
                          ]),
                        ],
                      ),
                    ]))
              ])); // Center
        })); // Page// Page
    pdf.save();
    // Navigator.pop(ctx);
    if (isP) {
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    } else {
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: '$InvoiceNo.pdf');
    }

    //Navigator.pop(ctx);

    // PdfPreview(
    //   build: (format) => pdf.save(),
    // );
  }
  //  print('End pf it');
}
