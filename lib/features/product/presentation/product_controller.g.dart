// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recommendedProductsHash() =>
    r'd79d588819a95b561bf3ac07ec17890555161b33';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [recommendedProducts].
@ProviderFor(recommendedProducts)
const recommendedProductsProvider = RecommendedProductsFamily();

/// See also [recommendedProducts].
class RecommendedProductsFamily extends Family<AsyncValue<List<Product>>> {
  /// See also [recommendedProducts].
  const RecommendedProductsFamily();

  /// See also [recommendedProducts].
  RecommendedProductsProvider call({
    required int? categoryId,
    required int currentProductId,
  }) {
    return RecommendedProductsProvider(
      categoryId: categoryId,
      currentProductId: currentProductId,
    );
  }

  @override
  RecommendedProductsProvider getProviderOverride(
    covariant RecommendedProductsProvider provider,
  ) {
    return call(
      categoryId: provider.categoryId,
      currentProductId: provider.currentProductId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recommendedProductsProvider';
}

/// See also [recommendedProducts].
class RecommendedProductsProvider
    extends AutoDisposeFutureProvider<List<Product>> {
  /// See also [recommendedProducts].
  RecommendedProductsProvider({
    required int? categoryId,
    required int currentProductId,
  }) : this._internal(
          (ref) => recommendedProducts(
            ref as RecommendedProductsRef,
            categoryId: categoryId,
            currentProductId: currentProductId,
          ),
          from: recommendedProductsProvider,
          name: r'recommendedProductsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recommendedProductsHash,
          dependencies: RecommendedProductsFamily._dependencies,
          allTransitiveDependencies:
              RecommendedProductsFamily._allTransitiveDependencies,
          categoryId: categoryId,
          currentProductId: currentProductId,
        );

  RecommendedProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
    required this.currentProductId,
  }) : super.internal();

  final int? categoryId;
  final int currentProductId;

  @override
  Override overrideWith(
    FutureOr<List<Product>> Function(RecommendedProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecommendedProductsProvider._internal(
        (ref) => create(ref as RecommendedProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
        currentProductId: currentProductId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Product>> createElement() {
    return _RecommendedProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendedProductsProvider &&
        other.categoryId == categoryId &&
        other.currentProductId == currentProductId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, currentProductId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RecommendedProductsRef on AutoDisposeFutureProviderRef<List<Product>> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;

  /// The parameter `currentProductId` of this provider.
  int get currentProductId;
}

class _RecommendedProductsProviderElement
    extends AutoDisposeFutureProviderElement<List<Product>>
    with RecommendedProductsRef {
  _RecommendedProductsProviderElement(super.provider);

  @override
  int? get categoryId => (origin as RecommendedProductsProvider).categoryId;
  @override
  int get currentProductId =>
      (origin as RecommendedProductsProvider).currentProductId;
}

String _$productHistoryHash() => r'6a7982f6853f619d35b6c5573120b7e379b9f5ab';

/// See also [ProductHistory].
@ProviderFor(ProductHistory)
final productHistoryProvider =
    NotifierProvider<ProductHistory, List<Product>>.internal(
  ProductHistory.new,
  name: r'productHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductHistory = Notifier<List<Product>>;
String _$productListHash() => r'f322982af7c21185c043da08d0d536e58a375f04';

abstract class _$ProductList
    extends BuildlessAutoDisposeAsyncNotifier<List<Product>> {
  late final ProductFilter filter;

  FutureOr<List<Product>> build(
    ProductFilter filter,
  );
}

/// See also [ProductList].
@ProviderFor(ProductList)
const productListProvider = ProductListFamily();

/// See also [ProductList].
class ProductListFamily extends Family<AsyncValue<List<Product>>> {
  /// See also [ProductList].
  const ProductListFamily();

  /// See also [ProductList].
  ProductListProvider call(
    ProductFilter filter,
  ) {
    return ProductListProvider(
      filter,
    );
  }

  @override
  ProductListProvider getProviderOverride(
    covariant ProductListProvider provider,
  ) {
    return call(
      provider.filter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productListProvider';
}

/// See also [ProductList].
class ProductListProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ProductList, List<Product>> {
  /// See also [ProductList].
  ProductListProvider(
    ProductFilter filter,
  ) : this._internal(
          () => ProductList()..filter = filter,
          from: productListProvider,
          name: r'productListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productListHash,
          dependencies: ProductListFamily._dependencies,
          allTransitiveDependencies:
              ProductListFamily._allTransitiveDependencies,
          filter: filter,
        );

  ProductListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final ProductFilter filter;

  @override
  FutureOr<List<Product>> runNotifierBuild(
    covariant ProductList notifier,
  ) {
    return notifier.build(
      filter,
    );
  }

  @override
  Override overrideWith(ProductList Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductListProvider._internal(
        () => create()..filter = filter,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProductList, List<Product>>
      createElement() {
    return _ProductListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductListProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProductListRef on AutoDisposeAsyncNotifierProviderRef<List<Product>> {
  /// The parameter `filter` of this provider.
  ProductFilter get filter;
}

class _ProductListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProductList, List<Product>>
    with ProductListRef {
  _ProductListProviderElement(super.provider);

  @override
  ProductFilter get filter => (origin as ProductListProvider).filter;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
