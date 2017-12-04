//
//  ServerBrowser.h
//  PacketSending
//
//  Created by JackYang on 21/09/15.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerBrowserDelegate <NSObject>

- (void) serverBrowserFoundService:(NSNetService*)service;
- (void) serverBrowserLostService:(NSNetService*)service index:(NSUInteger)index;

@end

@interface ServerBrowser : NSObject

- (id) initWithServerType:(NSString*)serverType port:(int16_t)port;

@property (readonly) NSArray* discoveredServers;

@property (readonly) NSString* serverType;
@property (readonly) int16_t port;
@property (nonatomic) NSString *severPath;

- (BOOL) isRunningServer;
- (void) createServer;
- (void) stopServer;
- (void) stopServerBrowser;

@property (weak) id<ServerBrowserDelegate> delegate;

@end
