import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/product.dart';
import 'package:shop_zone/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/editProductScreen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();
  final _imageInputController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  Product product =
      Product(id: null, title: '', description: '', price: null, imageUrl: '');

  var _isInit = true;
  var _loadingStatus = false;

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState.validate();

    if (!isValid) return;

    _formKey.currentState.save();

    setState(() {
      _loadingStatus = true;
    });

    if (product.id == null) {
      try {
        await Provider.of<Products>(context, listen: false).addProduct(product);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Some Error occured'),
            content: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Okay'),
              )
            ],
          ),
        );
      }
    } else {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(product);
    }
    setState(() {
      _loadingStatus = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final p = ModalRoute.of(context).settings.arguments as Product;
      if (p != null) product = p;
      _isInit = false;
      _imageInputController.text = product.imageUrl;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${product.id == null ? 'Create Product' : 'Edit Product'}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _loadingStatus
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: product.title,
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (val) {
                        if (val.isEmpty) return 'This field is required';
                        return null;
                      },
                      onSaved: (val) {
                        product = Product(
                            id: product.id,
                            title: val,
                            description: product.description,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            isFavorite: product.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue:
                          product.price == null ? '' : product.price.toString(),
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descFocusNode);
                      },
                      validator: (val) {
                        if (val.isEmpty) return 'This field is required';
                        if (double.tryParse(val) == null)
                          return 'Enter a valid number';
                        if (double.parse(val) <= 0) return 'Seriously bruh!';
                        return null;
                      },
                      onSaved: (val) {
                        product = Product(
                            id: product.id,
                            title: product.title,
                            description: product.description,
                            price: double.parse(val),
                            imageUrl: product.imageUrl,
                            isFavorite: product.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: product.description,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descFocusNode,
                      validator: (val) {
                        if (val.isEmpty) return 'This field is required';
                        if (val.length < 10)
                          return 'You can write more than 10 chars, right?';
                        return null;
                      },
                      onSaved: (val) {
                        product = Product(
                            id: product.id,
                            title: product.title,
                            description: val,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            isFavorite: product.isFavorite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 16, right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1.0),
                          ),
                          alignment: Alignment.center,
                          child: _imageInputController.text.isEmpty
                              ? Text('No Image')
                              : FittedBox(
                                  child: Image.network(
                                    _imageInputController.text,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image Url'),
                            textInputAction: TextInputAction.done,
                            controller: _imageInputController,
                            focusNode: _imageFocusNode,
                            onFieldSubmitted: (_) => _saveForm(),
                            validator: (val) {
                              if (val.isEmpty) return 'This field is required';
                              return null;
                            },
                            onSaved: (val) {
                              product = Product(
                                  id: product.id,
                                  title: product.title,
                                  description: product.description,
                                  price: product.price,
                                  imageUrl: val,
                                  isFavorite: product.isFavorite);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageUrl);
    _imageFocusNode.dispose();
    _descFocusNode.dispose();
    _priceFocusNode.dispose();
    _imageInputController.dispose();
    super.dispose();
  }
}
