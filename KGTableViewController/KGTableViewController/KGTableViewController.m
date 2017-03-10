//
//  KGTableViewController.m
//  KGTableViewController
//
//  Created by Kavita Gaitonde on 2/27/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

#import "KGTableViewController.h"

@interface Fruit : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIImage *image;
@end

@implementation Fruit

@end

@interface KGTableViewController () 
@property (nonatomic, strong) NSMutableArray *fruits;
@property (nonatomic, strong) NSOperationQueue *downloadQ;
@end


@implementation KGTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup fruits urls array
    [self setupFruits];
    
    if(self.kgType == KGNSOperation) {
        [self downloadOperations];
    }
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fruits count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndentifier = @"Fruit";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier /*forIndexPath:indexPath*/];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.imageView.backgroundColor = [UIColor blueColor];
    }
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    Fruit *fruit = self.fruits[indexPath.row];
    cell.textLabel.text = fruit.name;
    if (fruit.image) {
        cell.imageView.image = fruit.image;
    } else {
        if(self.kgType == KGDispatchAsync) {
            // download the image asynchronously
            NSLog(@"cellForRowAtIndexPath:started download - %@", fruit.name);
            [self downloadImageWithURL:[NSURL URLWithString:fruit.url] completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    // change the image in the cell
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imageView.image = image;
                        cell.imageView.backgroundColor = [UIColor clearColor];
                    });
                    // cache the image for use later (when scrolling up)
                    fruit.image = image;
                    
                    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    NSLog(@"cellForRowAtIndexPath:completed download - %@", fruit.name);
                }
            }];            
        }
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -  Setup fruits from plist

- (void)setupFruits
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"KGList" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *arr = [dict objectForKey:@"Fruits"];
    self.fruits = [NSMutableArray array];
    for(NSDictionary *d in arr) {
        Fruit *fruit = [[Fruit alloc] init];
        [fruit setName:[d objectForKey:@"Name"]];
        [fruit setUrl:[d objectForKey:@"Url"]];
        [self.fruits addObject:fruit];
    }
    NSLog(@"setupFruits - %@", self.fruits);
}

#pragma mark -  Asynchronous Download

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSLog(@"downloadImageWithURL:started for - %@", url.absoluteString);
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url
            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                if(error) {
                    completionBlock(NO, nil);
                } else {
                    UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    NSLog(@"downloadImageWithURL:completed for - %@", url.absoluteString);
                    completionBlock(YES, downloadedImage);
                }
    }];
    
    [downloadTask resume];
}

#pragma mark -  NSOperation Download

- (void)downloadOperations
{
    NSLog(@"downloadOperations:started");
    self.downloadQ = [[NSOperationQueue alloc] init];
    self.downloadQ.maxConcurrentOperationCount = 4;
    NSUInteger i = 0;
    for(Fruit *f in self.fruits) {
        [self.downloadQ addOperationWithBlock:^{
            NSURL *url = [NSURL URLWithString:f.url];
            [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image) {
                if(succeeded) {
                    f.image = image;
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }];
        }];
        i++;
    }
    

}

@end
