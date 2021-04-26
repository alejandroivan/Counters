
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - Base URL

extern NSString * const baseURL;

// MARK: - Completion Handler
typedef void (^JSONCompletionHandler) (id _Nullable object, NSError * _Nullable error);
typedef void (^DataCompletionHandler) (NSData * _Nullable data, NSError * _Nullable error);

// MARK: - Error
extern NSErrorDomain const CountersErrorDomain;

typedef NS_ENUM(NSInteger, CountersErrorCode) {
    CountersErrorCodeNoData = -777
};

// MARK: - Networking
@interface Networking : NSObject
- (NSURLSessionTask *)jsonRequestURL:(NSURL *)url
                          HTTPMethod:(NSString *)method
                          parameters:(NSDictionary<NSString*, NSString*>*)parameters
                   completionHandler:(JSONCompletionHandler)completion;

// MARK: - Convenience methods
- (void)getURL:(NSString * _Nonnull)urlString
    parameters:(NSArray<NSURLQueryItem *> * _Nullable)queryItem
completionHandler:(DataCompletionHandler)completion;

- (void)postURL:(NSString * _Nonnull)urlString
     parameters:(NSArray<NSURLQueryItem *> * _Nullable)queryItems
completionHandler:(DataCompletionHandler)completion;

- (void)deleteURL:(NSString * _Nonnull)urlString
       parameters:(NSArray<NSURLQueryItem *> * _Nullable)queryItem
completionHandler:(DataCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
