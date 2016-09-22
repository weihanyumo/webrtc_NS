//
//  DetailViewController.h
//  testNS
//
//  Created by duhaodong on 16/9/20.
//  Copyright © 2016年 duhaodong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

