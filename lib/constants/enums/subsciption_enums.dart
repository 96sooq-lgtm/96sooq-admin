enum SubscriptionType { productListing, advertisement }

extension SubscriptionTypeUI on SubscriptionType {
  String get label {
    switch (this) {
      case SubscriptionType.productListing:
        return 'Product Listing';
      case SubscriptionType.advertisement:
        return 'Advertisement';
    }
  }
}

extension SubscriptionTypeAPI on SubscriptionType {
  String get apiValue {
    switch (this) {
      case SubscriptionType.productListing:
        return 'listing';
      case SubscriptionType.advertisement:
        return 'ad';
    }
  }
}
