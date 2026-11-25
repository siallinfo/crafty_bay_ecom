// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crafty_bay_ecom/main.dart';
import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/core/app_typography.dart';
import 'package:crafty_bay_ecom/data/service/auth_service.dart';
import 'package:crafty_bay_ecom/data/service/cache/cache_service.dart';
import 'package:crafty_bay_ecom/presentation/features/auth/login/view/login_view.dart';
import 'package:crafty_bay_ecom/presentation/features/auth/sign_up/view/sign_up_view.dart';
import 'package:crafty_bay_ecom/presentation/features/auth/otp_verification/view/otp_verification_view.dart';
import 'package:crafty_bay_ecom/presentation/features/auth/complete_profile/view/complete_profile_view.dart';
import 'package:crafty_bay_ecom/presentation/features/cart/view/cart_view.dart';
import 'package:crafty_bay_ecom/presentation/features/categories/view/all_categories_view.dart';
import 'package:crafty_bay_ecom/presentation/features/category_products/view/category_products_view.dart';
import 'package:crafty_bay_ecom/presentation/features/create_review/view/create_review_view.dart';
import 'package:crafty_bay_ecom/presentation/features/home/view/home_view.dart';
import 'package:crafty_bay_ecom/presentation/features/product_details/view/product_details_view.dart';
import 'package:crafty_bay_ecom/presentation/features/payment/view/payment_view.dart';
import 'package:crafty_bay_ecom/presentation/features/profile/view/profile_view.dart';
import 'package:crafty_bay_ecom/presentation/features/reviews/view/reviews_view.dart';
import 'package:crafty_bay_ecom/presentation/features/splash/view/splash_view.dart';
import 'package:crafty_bay_ecom/presentation/features/wishlist/view/wishlist_view.dart';
import 'package:crafty_bay_ecom/presentation/core/app_bottom_nav_bar.dart';
import 'package:crafty_bay_ecom/presentation/core/bottom_bar_circle_button.dart';
import 'package:crafty_bay_ecom/presentation/core/category_card.dart';
import 'package:crafty_bay_ecom/presentation/core/product_card.dart';
import 'package:crafty_bay_ecom/presentation/core/product_grid_page.dart';
import 'package:crafty_bay_ecom/presentation/core/product_section.dart';
import 'package:crafty_bay_ecom/domain/entities/category.dart';
import 'package:crafty_bay_ecom/domain/entities/cart_item.dart';
import 'package:crafty_bay_ecom/domain/entities/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  dotenv.loadFromString(
    envString: 'API_BASE_URL=https://ecom-rs8e.onrender.com/api',
  );

  testWidgets('App configures a teal status bar with dark icons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CraftyBayApp());

    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(region.value.statusBarColor, AppColors.logoTeal);
    expect(region.value.statusBarIconBrightness, Brightness.dark);
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .theme
          ?.appBarTheme
          .systemOverlayStyle
          ?.statusBarColor,
      AppColors.logoTeal,
    );
  });

  testWidgets('Every button variant uses the shared label size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CraftyBayApp());

    final theme = tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
    final buttonStyles = [
      theme.elevatedButtonTheme.style,
      theme.textButtonTheme.style,
      theme.outlinedButtonTheme.style,
      theme.filledButtonTheme.style,
    ];

    for (final style in buttonStyles) {
      expect(
        style?.textStyle?.resolve(const <WidgetState>{})?.fontSize,
        AppTypography.buttonLabel.fontSize,
      );
    }
  });

  testWidgets('Splash opens login and registration is available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CraftyBayApp());

    expect(find.byType(SplashView), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Please Enter Your Email Address'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.textContaining("Don't have an account?"), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpView), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text(AppStrings.createAccount), findsNWidgets(2));
    expect(find.textContaining('Already have an account?'), findsOneWidget);
    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);

    final signInButton = tester.widget<TextButton>(
      find.ancestor(
        of: find.text(AppStrings.signIn),
        matching: find.byType(TextButton),
      ),
    );
    expect(
      signInButton.style?.foregroundColor?.resolve(const <WidgetState>{}),
      AppColors.primaryDark,
    );
    expect(
      signInButton.style?.padding?.resolve(const <WidgetState>{}),
      EdgeInsets.zero,
    );
    expect(
      signInButton.style?.minimumSize?.resolve(const <WidgetState>{}),
      Size.zero,
    );
    expect(signInButton.style?.tapTargetSize, MaterialTapTargetSize.shrinkWrap);
    final signInLabel = tester.widget<Text>(find.text(AppStrings.signIn));
    expect(signInLabel.style?.color, AppColors.primaryDark);
    expect(signInLabel.style?.fontWeight, FontWeight.w600);

    final createAccountButton = find.widgetWithText(
      ElevatedButton,
      'Create Account',
    );
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsNWidgets(2));
    expect(find.text(AppStrings.emailRequired), findsOneWidget);
    expect(find.text(AppStrings.passwordRequired), findsOneWidget);

    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('Signup sends an OTP and verification opens profile setup', (
    WidgetTester tester,
  ) async {
    final authService = _FakeOtpFlowAuthService();
    await tester.pumpWidget(
      MaterialApp(home: SignUpView(authService: authService)),
    );

    final signupFields = find.byType(TextFormField);
    await tester.enterText(signupFields.at(0), 'Amina');
    await tester.enterText(signupFields.at(1), 'Rahman');
    await tester.enterText(signupFields.at(2), 'customer@example.test');
    await tester.enterText(signupFields.at(3), 'password123');
    final signupButton = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(signupButton);
    await tester.tap(signupButton);
    await tester.pumpAndSettle();

    expect(authService.signupDetails, {
      'first_name': 'Amina',
      'last_name': 'Rahman',
      'email': 'customer@example.test',
      'password': 'password123',
    });
    expect(find.byType(OtpVerificationView), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));

    final otpFields = find.byType(TextField);
    for (var index = 0; index < 4; index++) {
      await tester.enterText(otpFields.at(index), '1234'[index]);
    }
    await tester.tap(find.text(AppStrings.next));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(authService.verifiedEmail, 'customer@example.test');
    expect(authService.verifiedOtp, '1234');
    expect(find.byType(CompleteProfileView), findsOneWidget);
    await tester.pump();
    final completedProfileFields = find.byType(TextFormField);
    expect(
      tester
          .widget<TextFormField>(completedProfileFields.at(0))
          .controller!
          .text,
      'Amina',
    );
    expect(
      tester
          .widget<TextFormField>(completedProfileFields.at(1))
          .controller!
          .text,
      'Rahman',
    );
    expect(
      tester
          .widget<TextFormField>(completedProfileFields.at(2))
          .controller!
          .text,
      '0123456789',
    );
    expect(
      tester
          .widget<TextFormField>(completedProfileFields.at(3))
          .controller!
          .text,
      'Dhaka',
    );
    expect(
      tester
          .widget<TextFormField>(completedProfileFields.at(4))
          .controller!
          .text,
      'Main Street',
    );
  });

  testWidgets(
    'Create review form displays fields and validates required input',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreateReviewView()));

      expect(find.text('Create Review'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Write Review'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('This field is required'), findsOneWidget);
    },
  );

  testWidgets('Wishlist and category pages reuse the product grid', (
    WidgetTester tester,
  ) async {
    final itemBuilder = (BuildContext context, int index) => ProductCard(
      image: const AssetImage('assets/images/shoe.png'),
      title: 'New Year Special Shoe 30',
      price: '\$100',
      rating: 4.8,
      onWishTap: () {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WishlistView(
          itemCount: 6,
          itemBuilder: itemBuilder,
          onNavigationTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wish List'), findsOneWidget);
    expect(find.byType(ProductGridPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        home: CategoryProductsView(
          categoryName: 'Electronics',
          itemCount: 6,
          itemBuilder: itemBuilder,
          onNavigationTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Electronics'), findsOneWidget);
    expect(find.byType(ProductGridPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Product section reuses the horizontal product row', (
    WidgetTester tester,
  ) async {
    var seeAllTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductSection(
            title: 'Popular',
            itemCount: 3,
            onSeeAllTap: () => seeAllTapped = true,
            itemBuilder: (_, _) => const ProductCard(
              image: AssetImage('assets/images/shoe.png'),
              title: 'New Year Special Shoe 30',
              price: '\$100',
              rating: 4.8,
              width: 116,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('See All'), findsOneWidget);
    expect(find.byType(ProductCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('See All'));
    expect(seeAllTapped, isTrue);
  });

  testWidgets('Home screen composes the reusable shop widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeView(loadData: _loadTestHomeData)),
    );
    await tester.pumpAndSettle();

    expect(find.text('All Categories'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.byType(CategoryCard), findsNWidgets(4));
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home profile action opens sign-in prompt when logged out', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.init();
    await tester.pumpWidget(
      MaterialApp(home: HomeView(loadData: _loadTestHomeData)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileView), findsOneWidget);
    expect(
      find.text('Sign in to view and manage your profile.'),
      findsOneWidget,
    );
    expect(find.text('Login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile shows account data and saves edited fields', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.init();
    await CacheService.saveAccessToken('profile-token');
    final authService = _FakeAuthService({
      'data': {
        'user': {
          'first_name': 'Amina',
          'last_name': 'Rahman',
          'email': 'amina@example.test',
          'phone': '0123456789',
          'city': 'Dhaka',
          'address': 'Main Street',
        },
      },
    });

    await tester.pumpWidget(
      MaterialApp(home: ProfileView(authService: authService)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amina Rahman'), findsOneWidget);
    expect(find.text('amina@example.test'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));
    final firstField = find.descendant(
      of: find.byType(TextFormField).first,
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(firstField).readOnly, isTrue);

    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Amina Noor');
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(authService.updatedFields?['first_name'], 'Amina Noor');
    expect(authService.updatedFields?['last_name'], 'Rahman');
    expect(find.text('Profile updated successfully'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile logout confirms and clears the current session', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.init();
    await CacheService.saveAccessToken('profile-token');
    final authService = _FakeAuthService({
      'user': {
        'first_name': 'Amina',
        'last_name': 'Rahman',
        'phone': '0123456789',
        'city': 'Dhaka',
        'address': 'Main Street',
      },
    });
    await tester.pumpWidget(
      MaterialApp(home: ProfileView(authService: authService)),
    );
    await tester.pumpAndSettle();
    final logoutButton = find.widgetWithText(ElevatedButton, 'Log out');
    await tester.ensureVisible(logoutButton);
    final logoutButtonStyle = tester.widget<ElevatedButton>(logoutButton).style;
    expect(
      logoutButtonStyle?.backgroundColor?.resolve(const <WidgetState>{}),
      AppColors.errorDark,
    );
    expect(
      logoutButtonStyle?.foregroundColor?.resolve(const <WidgetState>{}),
      AppColors.textOnPrimary,
    );
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Log out'),
      ),
    );
    await tester.pumpAndSettle();

    expect(CacheService.isLoggedIn, isFalse);
    expect(find.byType(LoginView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Product details opens reviews and the review form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProductDetailsView()));
    await tester.pumpAndSettle();

    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('Color'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final mediumChipFinder = find.ancestor(
      of: find.text('M'),
      matching: find.byType(ChoiceChip),
    );
    await tester.ensureVisible(find.text('M'));
    await tester.tap(find.text('M'));
    await tester.pumpAndSettle();
    final mediumChip = tester.widget<ChoiceChip>(mediumChipFinder);
    expect(mediumChip.selected, isTrue);
    expect(mediumChip.showCheckmark, isFalse);
    expect(mediumChip.selectedColor, AppColors.primary);
    expect(mediumChip.labelStyle?.color, AppColors.textOnPrimary);

    await tester.ensureVisible(find.text('Reviews'));
    await tester.tap(find.text('Reviews'));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewsView), findsOneWidget);
    expect(find.text('Rabbil Hasan'), findsWidgets);
    expect(find.text('Reviews (1000)'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(BottomBarCircleButton));
    await tester.pumpAndSettle();

    expect(find.byType(CreateReviewView), findsOneWidget);
  });

  testWidgets('Cart updates quantity, removes products, and opens payment', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CartView(loadCart: _loadTestCart)),
    );
    await tester.pumpAndSettle();

    expect(find.text('New Year Special Shoe'), findsNWidgets(4));
    expect(find.text('\$400.00'), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('\$500.00'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove item').first);
    await tester.pumpAndSettle();
    expect(find.text('New Year Special Shoe'), findsNWidgets(3));
    expect(find.text('\$300.00'), findsOneWidget);

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentView), findsOneWidget);
    expect(find.text('\$300.00'), findsOneWidget);
  });

  testWidgets('Home cart tab opens the cart page', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(loadData: _loadTestHomeData, loadCart: _loadTestCart),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    expect(find.byType(CartView), findsOneWidget);
    expect(find.text('New Year Special Shoe'), findsNWidgets(4));
  });

  testWidgets('Empty cart shows an empty state and disables checkout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CartView(loadCart: _loadTestCart)),
    );
    await tester.pumpAndSettle();

    for (var index = 0; index < 4; index++) {
      await tester.tap(find.byTooltip('Remove item').first);
      await tester.pumpAndSettle();
    }

    expect(find.text('Your cart is empty'), findsOneWidget);
    final checkoutButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Checkout'),
    );
    expect(checkoutButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Categories tab opens the all-categories grid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(loadData: _loadTestHomeData, loadCart: _loadTestCart),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    expect(find.byType(AllCategoriesView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AllCategoriesView),
        matching: find.byType(CategoryCard),
      ),
      findsNWidgets(4),
    );
    expect(
      find.descendant(
        of: find.byType(AllCategoriesView),
        matching: find.byType(AppBottomNavBar),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Electronics').first);
    await tester.pumpAndSettle();
    expect(find.byType(CategoryProductsView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ProductGridPage),
        matching: find.text('Electronics'),
      ),
      findsOneWidget,
    );
  });
}

Future<HomeData> _loadTestHomeData() async {
  const categories = [
    Category(
      id: 'electronics',
      title: 'Electronics',
      slug: 'electronics',
      description: '',
      icon: '',
    ),
    Category(
      id: 'food',
      title: 'Food',
      slug: 'food',
      description: '',
      icon: '',
    ),
    Category(
      id: 'fashion',
      title: 'Fashion',
      slug: 'fashion',
      description: '',
      icon: '',
    ),
    Category(
      id: 'furniture',
      title: 'Furniture',
      slug: 'furniture',
      description: '',
      icon: '',
    ),
  ];
  const products = [
    Product(
      id: 'shoe-1',
      title: 'New Year Special Shoe 30',
      slug: 'shoe-1',
      description: '',
      photos: ['assets/images/shoe.png'],
      regularPrice: 100,
      currentPrice: 100,
      quantity: 10,
      categoryIds: ['electronics'],
    ),
    Product(
      id: 'shoe-2',
      title: 'New Year Special Shoe 30',
      slug: 'shoe-2',
      description: '',
      photos: ['assets/images/shoe.png'],
      regularPrice: 100,
      currentPrice: 100,
      quantity: 10,
    ),
    Product(
      id: 'shoe-3',
      title: 'New Year Special Shoe 30',
      slug: 'shoe-3',
      description: '',
      photos: ['assets/images/shoe.png'],
      regularPrice: 100,
      currentPrice: 100,
      quantity: 10,
    ),
  ];
  return const HomeData(categories: categories, products: products, slides: []);
}

Future<List<CartItem>> _loadTestCart() async => List.generate(
  4,
  (index) => CartItem(
    id: 'cart-$index',
    productId: 'shoe-$index',
    title: 'New Year Special Shoe',
    photo: 'assets/images/shoe.png',
    price: 100,
    quantity: 1,
    color: 'Red',
    size: 'X',
  ),
);

class _FakeAuthService extends AuthService {
  _FakeAuthService(this.profile);

  final Map<String, dynamic> profile;
  Map<String, dynamic>? updatedFields;

  @override
  Future<Map<String, dynamic>> getProfile() async => profile;

  @override
  Future<void> updateProfile(Map<String, dynamic> details) async {
    updatedFields = details;
  }
}

class _FakeOtpFlowAuthService extends AuthService {
  Map<String, dynamic>? signupDetails;
  String? verifiedEmail;
  String? verifiedOtp;

  @override
  Future<void> signup(Map<String, dynamic> details) async {
    signupDetails = details;
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    verifiedEmail = email;
    verifiedOtp = otp;
  }

  @override
  Future<Map<String, dynamic>> getProfile() async => {
    'user': {
      'first_name': 'Amina',
      'last_name': 'Rahman',
      'phone': '0123456789',
      'city': 'Dhaka',
      'address': 'Main Street',
    },
  };
}
