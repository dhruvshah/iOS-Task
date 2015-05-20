//
//  ViewController.m
//  testSample
//
//  Created by Dhruv Shah on 5/7/15.
//  Copyright (c) 2015 Dhruv Shah. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong , nonatomic) NSArray *array;
@property (strong , nonatomic) NSMutableArray *titleArray;  //Array to store titles
@property (strong , nonatomic) NSMutableArray *media; //Array to store imageURLs
@property (strong ,nonatomic) NSMutableArray *tableItems; //Array to store images

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    self.tableItems = [[NSMutableArray alloc] init];
    self.titleArray = [[NSMutableArray alloc] init];
    self.media = [[NSMutableArray alloc] init];
    
    [self fetchDataFromWebService]; //function to fetch data from webservice
   
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)fetchDataFromWebService{  //function to fetch data from webservice
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center=self.tableView.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    self.tableView.hidden = YES;
    
    
    NSURL *url = [NSURL URLWithString:@"http://api.nytimes.com/svc/topstories/v1/home.json?api-key=15629235341919a7b4b8b6e9344f9bca:6:72095783"];  // URL string provided
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {  //function block to handle response
         if (data.length > 0 && connectionError == nil)  /* check for a valid response */
         {
             NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:0
                                                                          error:NULL]; /* store JSON data in NSDictionary */
             NSArray *results = [dictionary objectForKey:@"results"];
             
             for (int i=0; i<results.count; i++) {
                 NSDictionary *resultsDictionary = [results objectAtIndex:i];
                 [self.titleArray addObject:[resultsDictionary objectForKey:@"title"]]; /* Array to store titles */
                 
                 if ([[resultsDictionary objectForKey:@"multimedia"] isKindOfClass:[NSArray class]]) {
                     NSArray *mediaImages = [resultsDictionary objectForKey:@"multimedia"];
                     NSDictionary *mediaUrlDictionary  = [mediaImages objectAtIndex:0];
                     [self.media addObject:[mediaUrlDictionary objectForKey:@"url"]]; /* Array to store image URLs */
                 }
                 else{
                     [self.media addObject:@"No Media"];
                 }
             }
             
             self.tableView.hidden = NO;
             [activityView stopAnimating];
             [activityView removeFromSuperview];
             [self.tableView reloadData];  /* reload the Table View */
             [self Downloadimages];  /* function to store images in array */
             
         }
         
     }];
    
}

-(void)Downloadimages{  //function to add images to the array

//    dispatch_async   /* to get images asynchronously */
//    
//    (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//    });
    
    for (int i=0; i<self.media.count; i++) {
        
        NSString *url = [self.media objectAtIndex:i];
        if (![url isEqualToString:@"No Media"]) {
            UIImage *img = nil;
            
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
            
            img = [[UIImage alloc] initWithData:data];
            [self.tableItems addObject:img];  /* Array to store images */
        }
        else{
            UIImage *img = nil;    /* case for no images */
            
            img = [UIImage imageNamed:@"noImage"];
            [self.tableItems addObject:img];  /* Array to store images */
            
        }
    }
    [self.tableView reloadData];  /* reload the Table View */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count; /* specify the rows */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"TableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TableViewCell"];
    }
    
    cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.item];   /* set Titles in rows */
    
    if (self.tableItems.count == self.titleArray.count) {
        
        //[activityView stopAnimating];
        //image.image = [self.tableItems objectAtIndex:indexPath.item];
        //[cell addSubview:image];
        cell.imageView.image = [self.tableItems objectAtIndex:indexPath.item]; /* set images in rows */
    }
    
    return cell;
}

@end
