#import "CATHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPResponse.h"
#import "HTTPDynamicFileResponse.h"
#import "GCDAsyncSocket.h"
#import "HTTPLogging.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <objc/runtime.h>
#import "HTTPDataResponse.h"
#import <UIKit/UIKit.h>
#import "HPCViewController.h"



// Log levels: off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;


@implementation CATHTTPConnection

- (WebSocket *)webSocketForURI:(NSString *)path
{
	HTTPLogTrace2(@"%@[%p]: webSocketForURI: %@", THIS_FILE, self, path);

	return [super webSocketForURI:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
	if([method isEqualToString:@"POST"] && [path hasPrefix:@"/cat"])
	{
		HTTPLogInfo(@"MyHTTPConnection: Got cat request");
        NSData *postData = [request body];
		if (postData)
		{
			NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
            NSError *error;
            NSData *data = [postStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary * postDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!error)
            {
                NSString *ip = [postDict objectForKey:@"ip"];
                NSString *port = [postDict objectForKey:@"port"];
                NSLog(@"Got request to launch: %@:%@",ip,port);
                UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                HPCViewController *webVC = (HPCViewController *)vc;
                if (webVC) {
                    [webVC navigateToUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",ip,port]]];
                }
            }
        }
		return [[HTTPDataResponse alloc] initWithData:[@"OK" dataUsingEncoding:NSUTF8StringEncoding]];
	}
	return [super httpResponseForMethod:method URI:path];
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
	
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	BOOL result = [request appendData:postDataChunk];
	if (!result)
	{
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	if ([method isEqualToString:@"POST"])
		return YES;
    else
        return [super supportsMethod:method atPath:path];
    
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

@end
