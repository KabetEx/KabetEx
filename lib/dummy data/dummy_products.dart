import 'package:kabetex/models/product.dart';
import 'package:kabetex/dummy data/dummy_categories.dart';

final List<Product> dummyProducts = [
  Product(
    id: '1',
    name: 'Apple iPhone 13',
    category: categories[3]['name'],
    price: 120000.99,
    imageUrl:
        'https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-13-pro-family-hero',
    description:
        'The latest iPhone with advanced features and improved performance.',
  ),
  Product(
    id: '2',
    name: 'Nike Air Max',
    category: categories[5]['name'],
    price: 12000.99,
    imageUrl:
        'https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/3c5f1e1f-3f4e-4d6e-8f6e-5b6e5f6e5f6e/air-max-270-shoe-KkLcGR.png',
    description: 'Comfortable and stylish sneakers for everyday wear.',
  ),
  Product(
    id: '3',
    name: 'The Great Gatsby',
    category: categories[5]['name'],
    price: 1200.99,
    imageUrl:
        'https://images-na.ssl-images-amazon.com/images/I/81af+MCATTL.jpg',
    description:
        'A classic novel by F. Scott Fitzgerald that explores themes of decadence and excess.',
  ),
  //food
  Product(
    id: '4',
    name: 'Organic Bananas',
    category: categories[4]['name'],
    price: 150.29,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/8/8a/Banana-Single.jpg',
    description: 'Fresh organic bananas sourced from local farms.',
  ),
];
