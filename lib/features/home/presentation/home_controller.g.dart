// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryListHash() => r'068ab61dc5b2142e9be3e1adf76466dbd6b74318';

/// See also [categoryList].
@ProviderFor(categoryList)
final categoryListProvider = AutoDisposeFutureProvider<List<Category>>.internal(
  categoryList,
  name: r'categoryListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoryListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoryListRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$homeDataHash() => r'72c649200f50730a06a7c85f7237d88a2aa349ea';

/// See also [homeData].
@ProviderFor(homeData)
final homeDataProvider = AutoDisposeFutureProvider<HomeData>.internal(
  homeData,
  name: r'homeDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$homeDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HomeDataRef = AutoDisposeFutureProviderRef<HomeData>;
String _$locationListHash() => r'b16291aaa2851f103c5ce0877ab201ff9390302d';

/// See also [locationList].
@ProviderFor(locationList)
final locationListProvider = AutoDisposeFutureProvider<List<Location>>.internal(
  locationList,
  name: r'locationListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$locationListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LocationListRef = AutoDisposeFutureProviderRef<List<Location>>;
String _$selectedLocationHash() => r'fcf916bae6e7d520263558654eb22776639ac589';

/// See also [SelectedLocation].
@ProviderFor(SelectedLocation)
final selectedLocationProvider =
    AutoDisposeAsyncNotifierProvider<SelectedLocation, Location>.internal(
  SelectedLocation.new,
  name: r'selectedLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedLocation = AutoDisposeAsyncNotifier<Location>;
String _$productListHash() => r'2a761df8edffa07a7f67f68c9c55cb92e3d130b7';

/// See also [ProductList].
@ProviderFor(ProductList)
final productListProvider =
    AutoDisposeAsyncNotifierProvider<ProductList, List<Product>>.internal(
  ProductList.new,
  name: r'productListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$productListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductList = AutoDisposeAsyncNotifier<List<Product>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
