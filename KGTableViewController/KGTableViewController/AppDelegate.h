//
//  AppDelegate.h
//  KGTableViewController
//
//  Created by Kavita Gaitonde on 2/26/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

