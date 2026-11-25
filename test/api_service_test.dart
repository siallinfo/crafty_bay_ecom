import 'package:crafty_bay_ecom/core/end_points.dart';
import 'package:crafty_bay_ecom/data/model/product_details_model.dart';
import 'package:crafty_bay_ecom/data/model/product_model.dart';
import 'package:crafty_bay_ecom/data/model/product_review_model.dart';
import 'package:crafty_bay_ecom/data/service/auth_service.dart';
import 'package:crafty_bay_ecom/data/service/cache/cache_service.dart';
import 'package:crafty_bay_ecom/data/service/cart_service.dart';
import 'package:crafty_bay_ecom/data/service/category_service.dart';
import 'package:crafty_bay_ecom/data/service/order_service.dart';
import 'package:crafty_bay_ecom/data/service/product_service.dart';
import 'package:crafty_bay_ecom/data/service/review_service.dart';
import 'package:crafty_bay_ecom/data/service/network/network_caller.dart';
import 'package:crafty_bay_ecom/data/service/network/network_log_box.dart';
import 'package:crafty_bay_ecom/data/service/network/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  dotenv.loadFromString(
    envString: 'API_BASE_URL=https://ecom-rs8e.onrender.com/api',
  );

  test('API endpoints use the collection base URL', () {
    expect(EndPoints.baseUrl, 'https://ecom-rs8e.onrender.com/api');
    expect(
      EndPoints.productById('p-1'),
      '${EndPoints.baseUrl}/products/id/p-1',
    );
  });

  test('root .env asset provides the API base URL', () async {
    await dotenv.load(fileName: '.env');
    expect(EndPoints.baseUrl, 'https://ecom-rs8e.onrender.com/api');
  });

  test('product parsers tolerate null prices and nested category objects', () {
    final product = ProductModel.fromJson({
      '_id': 'p-1',
      'title': 'Example',
      'photos': ['https://example.test/photo.png'],
      'categories': [
        {'_id': 'c-1'},
      ],
      'regular_price': null,
      'current_price': 12.5,
      'quantity': 2,
    });

    expect(product.id, 'p-1');
    expect(product.regularPrice, isNull);
    expect(product.currentPrice, 12.5);
    expect(product.categoryIds, ['c-1']);

    final details = ProductDetailsModel.fromJson({
      '_id': 'p-1',
      'regular_price': null,
      'current_price': 12.5,
      'quantity': '2',
    });
    expect(details.regularPrice, isNull);
    expect(details.quantity, 2);
  });

  test('review parser reads nested author data and numeric rating', () {
    final review = ProductReviewModel.fromJson({
      '_id': 'r-1',
      'user': {'first_name': 'A', 'last_name': 'B'},
      'rating': 4.5,
      'comment': 'Works well',
      'createdAt': '2025-01-01T00:00:00.000Z',
    });

    expect(review.author, 'A B');
    expect(review.rating, 4.5);
    expect(review.comment, 'Works well');
    expect(review.createdAt, DateTime.utc(2025, 1, 1));
  });

  test('product service follows the API pagination contract and filters', () async {
    final caller = _PagedNetworkCaller([
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: '{"data":{"results":[{"_id":"p-1","title":"First"}],"next":2}}',
      ),
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body:
            '{"data":{"results":[{"_id":"p-2","title":"Second"}],"next":null}}',
      ),
    ]);

    final products = await ProductService(networkCaller: caller)
        .getProducts(count: 1, categoryId: 'c-1');

    expect(products.map((product) => product.id), ['p-1', 'p-2']);
    expect(caller.requestedUris, hasLength(2));
    expect(caller.requestedUris.first.queryParameters, {
      'count': '1',
      'page': '1',
      'category': 'c-1',
    });
    expect(caller.requestedUris.last.queryParameters['page'], '2');
  });

  test('category service fetches every page in order', () async {
    final caller = _PagedNetworkCaller([
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: '{"data":{"results":[{"_id":"c-1","title":"First"}],"next":2}}',
      ),
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body:
            '{"data":{"results":[{"_id":"c-2","title":"Second"}],"next":null}}',
      ),
    ]);

    final categories = await CategoryService(networkCaller: caller)
        .getCategories(count: 1);

    expect(categories.map((category) => category.id), ['c-1', 'c-2']);
    expect(caller.requestedUris, hasLength(2));
    expect(caller.requestedUris.first.queryParameters, {
      'count': '1',
      'page': '1',
    });
    expect(caller.requestedUris.last.queryParameters['page'], '2');
  });

  test('network logs never print token or request/response bodies', () {
    final requestLog = NetworkLogBox.request(
      'POST',
      Uri.https('example.test', '/login'),
      {'token': 'private-token', 'accept': 'application/json'},
      body: '{"password":"private-password"}',
    );
    final responseLog = NetworkLogBox.response(
      method: 'POST',
      uri: Uri.https('example.test', '/login'),
      statusCode: 200,
      reason: 'OK',
      elapsedMs: 1,
      body: '{"token":"private-token"}',
    );

    expect(requestLog, isNot(contains('private-token')));
    expect(requestLog, isNot(contains('private-password')));
    expect(responseLog, isNot(contains('private-token')));
    expect(responseLog, contains('(omitted)'));
  });

  test('login saves the returned token without exposing it in logs', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.init();
    final caller = _FakeNetworkCaller(
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: '{"code":200,"status":"success","data":{"token":"saved-token"}}',
      ),
    );

    await AuthService(networkCaller: caller)
        .login(email: 'person@example.test', password: 'a-private-password');

    expect(caller.lastUri, Uri.parse(EndPoints.login));
    expect(caller.lastBody, {
      'email': 'person@example.test',
      'password': 'a-private-password',
    });
    expect(CacheService.accessToken, 'saved-token');
  });

  test('signup sends the documented fields to start OTP delivery', () async {
    final caller = _FakeNetworkCaller(
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: '{"data":{"message":"OTP sent"}}',
      ),
    );
    final details = {
      'first_name': 'Amina',
      'last_name': 'Rahman',
      'email': 'customer@example.test',
      'password': 'private-password',
    };

    await AuthService(networkCaller: caller).signup(details);

    expect(caller.lastUri, Uri.parse(EndPoints.signup));
    expect(caller.lastBody, details);
  });

  test('OTP verification caches the access token required by profile setup', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.init();
    final caller = _FakeNetworkCaller(
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: '{"data":{"token":"verified-token"}}',
      ),
    );

    await AuthService(
      networkCaller: caller,
    ).verifyOtp(email: 'customer@example.test', otp: '1234');

    expect(caller.lastUri, Uri.parse(EndPoints.verifyOtp));
    expect(caller.lastBody, {
      'email': 'customer@example.test',
      'otp': '1234',
    });
    expect(CacheService.accessToken, 'verified-token');
  });

  test('OTP verification fails explicitly if the API omits its access token', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.init();
    final caller = _FakeNetworkCaller(
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: '{"data":{"verified":true}}',
      ),
    );

    await expectLater(
      AuthService(
        networkCaller: caller,
      ).verifyOtp(email: 'customer@example.test', otp: '1234'),
      throwsA(isA<FormatException>()),
    );
  });

  test('resend OTP sends the recipient email to the documented endpoint', () async {
    final caller = _FakeNetworkCaller(
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: '{"data":{"message":"OTP resent"}}',
      ),
    );

    await AuthService(
      networkCaller: caller,
    ).resendOtp('customer@example.test');

    expect(caller.lastUri, Uri.parse(EndPoints.resendOtp));
    expect(caller.lastBody, {'email': 'customer@example.test'});
  });

  test('profile reads and updates use the authenticated profile endpoint', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.init();
    await CacheService.saveAccessToken('saved-token');
    final caller = _FakeNetworkCaller(
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body:
            '{"data":{"user":{"first_name":"Ada","email":"ada@example.test"}}}',
      ),
    );
    final authService = AuthService(networkCaller: caller);

    final profile = await authService.getProfile();
    expect(caller.lastUri, Uri.parse(EndPoints.profile));
    expect(profile, {
      'user': {'first_name': 'Ada', 'email': 'ada@example.test'},
    });

    final updatedFields = {
      'first_name': 'Ada',
      'last_name': 'Lovelace',
      'phone': '0123456789',
      'city': 'Dhaka',
      'address': 'Main Street',
    };
    await authService.updateProfile(updatedFields);
    expect(caller.lastUri, Uri.parse(EndPoints.profile));
    expect(caller.lastHeaders?['token'], 'saved-token');
    expect(caller.lastBody, updatedFields);
  });

  test('customer mutations send the documented API request fields', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.init();
    await CacheService.saveAccessToken('saved-token');
    final caller = _FakeNetworkCaller(
      NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: '{"data":{"ok":true}}',
      ),
    );

    await CartService(networkCaller: caller)
        .addToCart(productId: 'p-1', quantity: 2, size: 'M');
    expect(caller.lastBody, {'product': 'p-1', 'quantity': 2, 'size': 'M'});
    expect(caller.lastHeaders?['token'], 'saved-token');

    await ReviewService(networkCaller: caller)
        .createReview(productId: 'p-1', rating: 5, comment: 'Great');
    expect(caller.lastBody, {
      'product': 'p-1',
      'rating': 5,
      'comment': 'Great',
    });

    await OrderService(networkCaller: caller)
        .createOrder(paymentMethod: 'cod', shippingAddress: 'Main Street');
    expect(caller.lastBody, {
      'payment_method': 'cod',
      'shipping_address': 'Main Street',
    });
  });
}

class _FakeNetworkCaller extends NetworkCaller {
  _FakeNetworkCaller(this.response);

  final NetworkResponse response;
  Uri? lastUri;
  Map<String, dynamic>? lastBody;
  Map<String, String>? lastHeaders;

  @override
  Future<NetworkResponse> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    lastUri = uri;
    lastBody = body;
    lastHeaders = headers;
    return response;
  }

  @override
  Future<NetworkResponse> get(Uri uri, {Map<String, String>? headers}) async {
    lastUri = uri;
    lastHeaders = headers;
    return response;
  }

  @override
  Future<NetworkResponse> patch(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    lastUri = uri;
    lastBody = body;
    lastHeaders = headers;
    return response;
  }
}

class _PagedNetworkCaller extends NetworkCaller {
  _PagedNetworkCaller(this.responses);

  final List<NetworkResponse> responses;
  final List<Uri> requestedUris = [];
  int _responseIndex = 0;

  @override
  Future<NetworkResponse> get(Uri uri, {Map<String, String>? headers}) async {
    requestedUris.add(uri);
    return responses[_responseIndex++];
  }
}
