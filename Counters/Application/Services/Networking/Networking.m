
#import "Networking.h"

// MARK: - Base URL
// TODO: Rollback to 127.0.0.1
NSString *const baseURL = @"http://192.168.0.4:3000";

// MARK: - Error
NSErrorDomain const CountersErrorDomain = @"counters.network.error.domain";

// MARK: - Headers
NSString * const ContentType = @"Content-Type";
NSString * const JSONContentType = @"application/json";

// MARK: - Handlers
typedef void (^DataCompletionHandler) (NSData * _Nullable data, NSError * _Nullable error);

@interface Networking ()
@property (nonatomic, strong) NSURLSession *client;
@end

@implementation Networking

- (instancetype)init
{
    self = [super init];
    if (self) {
        __auto_type *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _client = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (NSURLSessionTask *)jsonRequestURL:(NSURL *)url
                          HTTPMethod:(NSString *)method
                          parameters:(NSDictionary<NSString*, NSString*>*)parameters
                   completionHandler:(JSONCompletionHandler)completion
{
    return [self dataRequestURL:url HTTPMethod:method parameters:parameters completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            completion(nil, error);
            return;
        }
        completion(object, nil);
    }];
}

- (NSURLSessionTask *)dataRequestURL:(NSURL *)url
                      HTTPMethod:(NSString *)method
                      parameters:(NSDictionary<NSString*, NSString*>*)parameters
               completionHandler:(DataCompletionHandler)completion
{
    __auto_type *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = method;

    if (parameters) {
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        if (JSONData) {
            request.HTTPBody = JSONData;
            [request setValue:JSONContentType forHTTPHeaderField:ContentType];
        }
    }

    return [self.client dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(data, error);
        } else if (!data) {
            completion(nil, [self error:CountersErrorCodeNoData]);
        } else {
            completion(data, nil);
        }
    }];
}


- (NSError *)error:(CountersErrorCode)code
{
    return [NSError errorWithDomain:CountersErrorDomain
                               code:code
                           userInfo:nil];
}

// We could use NSURLComponents in here, but for the sake of time, an array of NSURLQueryItems will do just fine.
// Either way, these should be translated to a URL query string, so no real impact.
- (void)getURL:(NSString * _Nonnull)urlString parameters:(NSArray<NSURLQueryItem *> * _Nullable)queryItems completionHandler:(DataCompletionHandler)completion {
    // Since GET requests don't have a body, we'll need to append the queryString to the actual URL string.
    NSDictionary *parameters = [self parametersFromQueryItems:queryItems];
    NSString *queryString = [self queryStringFrom:parameters];
    urlString = [NSString stringWithFormat:@"%@%@%@", baseURL, urlString, queryString];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionTask *task = [self dataRequestURL:url
                                       HTTPMethod:@"GET"
                                       parameters:nil
                                completionHandler:completion];
    [task resume];
}

- (void)postURL:(NSString * _Nonnull)urlString parameters:(NSArray<NSURLQueryItem *> * _Nullable)queryItems completionHandler:(DataCompletionHandler)completion {
    NSDictionary *parameters = [self parametersFromQueryItems:queryItems];
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, urlString];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionTask *task = [self dataRequestURL:url
                                       HTTPMethod:@"POST"
                                       parameters:parameters
                                completionHandler:completion];
    [task resume];
}

- (void)deleteURL:(NSString * _Nonnull)urlString parameters:(NSArray<NSURLQueryItem *> * _Nullable)queryItems completionHandler:(DataCompletionHandler)completion {
    NSDictionary *parameters = [self parametersFromQueryItems:queryItems];
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, urlString];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionTask *task = [self dataRequestURL:url
                                       HTTPMethod:@"DELETE"
                                       parameters:parameters
                                completionHandler:completion];
    [task resume];
}

// MARK: - Helper methods

- (NSDictionary *)parametersFromQueryItems:(NSArray<NSURLQueryItem *> * _Nonnull)queryItems {
    NSMutableDictionary *parameters = [NSMutableDictionary new];

    if (queryItems != nil) {
        for (NSURLQueryItem *item in queryItems) {
            if (item.value == nil) continue; // item.name is _Nonnull, so we'll just validate value.
            parameters[item.name] = item.value;
        }
    }

    return parameters.copy;
}

- (NSString * _Nonnull)queryStringFrom:(NSDictionary * _Nonnull)parameters {
    NSMutableString *queryString = [@"" mutableCopy];

    for (NSString *key in parameters.allKeys) {
        NSString *value = parameters[key];
        value = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *safeKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        if (queryString.length == 0) [queryString appendString:@"?"];
        else [queryString appendString:@"&"];

        [queryString appendFormat:@"%@=%@", safeKey, value];
    }

    return queryString.copy;
}

@end
