//
//  KGTableViewController.h
//  KGTableViewController
//
//  Created by Kavita Gaitonde on 2/27/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KGType) {
    KGDispatchAsync,
    KGNSOperation
};

@interface KGTableViewController : UITableViewController <NSURLSessionDelegate>

@property (nonatomic, assign) KGType kgType;

@end
