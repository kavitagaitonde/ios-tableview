//
//  ViewController.m
//  KGTableViewController
//
//  Created by Kavita Gaitonde on 2/26/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonTableViewController;
@property (weak, nonatomic) IBOutlet UIButton *operationTableViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchTableViewController:(id)sender {
    NSLog(@"launchTableViewController");
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    KGTableViewController *vc = segue.destinationViewController;
    if(sender == self.buttonTableViewController) {
        [vc setKgType:KGDispatchAsync];
    } else if (sender == self.operationTableViewController) {
        [vc setKgType:KGNSOperation];
    } else {
        NSLog(@"Unknown segue");
    }
    
}

@end
