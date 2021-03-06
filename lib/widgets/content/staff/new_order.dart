import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mostaza/backend/staff.dart';
import 'package:mostaza/constants/app_icons_icons.dart';
import 'package:mostaza/constants/colors.dart';
import 'package:mostaza/constants/number_format.dart';
import 'package:mostaza/models/discount.dart';
import 'package:mostaza/models/order.dart';
import 'package:mostaza/models/product.dart';
import 'package:mostaza/models/user.dart';
import 'package:mostaza/screens/content/staff/search.dart';
import 'package:mostaza/widgets/components/button.dart';
import 'package:mostaza/widgets/components/create_order_item.dart';
import 'package:mostaza/widgets/components/input.dart';

class NewOrder extends StatefulWidget {
  final controllerId = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerTable = TextEditingController();
  final controllerDiscount = TextEditingController();
  final List<Product> products = [];
  final User user;
  final GlobalKey<ScaffoldState> scaffoldKey;

  NewOrder({Key key, @required this.user, @required this.scaffoldKey})
      : super(key: key);
  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  int _total;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _total = 0;
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, index) {
                if (index == 0) {
                  return _form();
                } else if (index != widget.products.length + 1) {
                  Product product = widget.products[index - 1];
                  return CreateOrderTile(
                      product: product,
                      onMinusPressed: () {
                        setState(() {
                          product.removeUnit();
                          if (product.quantity == '0') {
                            widget.products.remove(product);
                          }
                          _total = _total - int.parse(product.price);
                        });
                      },
                      onPlusPressed: () {
                        setState(() {
                          product.addUnit();
                          _total = _total + int.parse(product.price);
                        });
                      });
                } else {
                  return IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: AppColors.dixie,
                        size: 42.0,
                      ),
                      onPressed: () {
                        _showSearch(context);
                      });
                }
              },
              itemCount: widget.products.length + 2,
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, bottom: 8.0, right: 8.0),
                  child: Button(
                    height: 38.0,
                    color: AppColors.white,
                    onPressed: () => _clearForm(),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          textStyle: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0),
                  child: Button(
                    height: 38.0,
                    color: AppColors.dixie,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _onCreateOrder();
                      }
                    },
                    child: Text(
                      'Confirmar',
                      style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          textStyle: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Form _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Datos",
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Input(
            hintText: 'Id. del cliente',
            validator: (value) {
              if (value.isEmpty) {
                return 'Por favor ingrese la identificación del cliente';
              } else if (value.length < 8) {
                return 'Ingrese un numero de identificación válido';
              }
              return null;
            },
            controller: widget.controllerId,
            inputType: TextInputType.number,
            icon: Icon(
              AppIcons.person_id,
              size: 20.0,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Input(
            hintText: 'Correo electrónico',
            validator: (value) {
              if (value.isEmpty) {
                return 'Por favor ingrese el correo electronico del cliente';
              }
              return null;
            },
            controller: widget.controllerEmail,
            inputType: TextInputType.emailAddress,
            icon: Icon(
              AppIcons.person_id,
              size: 20.0,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Input(
            hintText: 'No. Mesa',
            validator: (value) {
              if (value.isEmpty) {
                return 'Por favor ingrese el numero de la mesa';
              }
              return null;
            },
            controller: widget.controllerTable,
            inputType: TextInputType.number,
            icon: Icon(
              AppIcons.number,
              size: 20.0,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Input(
            hintText: 'Descuento',
            validator: (value) {
              if (value.length != 5 && !value.isEmpty) {
                return 'Ingrese un código de descuento valido';
              }
              return null;
            },
            controller: widget.controllerDiscount,
            icon: Icon(
              AppIcons.price_tag,
              size: 20.0,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Platos",
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Expanded(
                child: Text(
                  "Total:",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                Formatter.currency.format(_total),
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              )
            ],
          ),
          SizedBox(
            height: 12.0,
          )
        ],
      ),
    );
  }

  _showSearch(context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchMenu()),
    );
    if (result != null) {
      setState(() {
        widget.products.add(result);
        _total = _total + int.parse(result.price);
      });
    }
  }

  _clearForm() {
    widget.controllerId.clear();
    widget.controllerTable.clear();
    widget.controllerDiscount.clear();
    widget.controllerEmail.clear();
    setState(() {
      widget.products.clear();
      _total = 0;
    });
  }

  _onCreateOrder() {
    fetchDiscount(
      widget.controllerEmail.text,
      widget.controllerDiscount.text,
    ).then(
      (discount) {
        Discount _discount = discount[0];
        String cuid = discount[1];
        if (_discount != null) {
          claimDiscount(cuid, _discount).then(
            (valid) {
              if (valid) {
                _createOrder(
                    (_total - int.parse(_discount.quantity)).toString(),
                    cuid,
                    _discount.quantity,
                    _discount.key);
              } else {
                _createOrder(_total.toString(), cuid, "0", "NA");
              }
            },
          ).catchError(
            (error) {},
          );
        } else {
          _createOrder(_total.toString(), cuid, "0", "NA");
        }
      },
    ).catchError(
      (error) {},
    );
  }

  _createOrder(String orderTotal, String cuid, String orderDiscount,
      String orderDiscountKey) {
    Order order = Order(
      number: Random().nextInt(99999999).toString().padLeft(8, '0'),
      total: orderTotal,
      costumerUid: cuid,
      discount: orderDiscount,
      costumerEmail: widget.controllerEmail.text,
      costumerId: widget.controllerId.text,
      tableNumber: widget.controllerTable.text,
      dishes: List.from(widget.products),
      discountId: orderDiscountKey,
    );
    createOrder(widget.user.uid, order).then(
      (created) {
        if (created) {
          _clearForm();
        } else {
          widget.scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('No se creo la orden'),
            ),
          );
        }
      },
    ).catchError(
      (error) {},
    );
  }
}
