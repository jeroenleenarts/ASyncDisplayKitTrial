//
//  GoogleImagesDatasource.m
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 01-03-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "GoogleImagesDatasource.h"

@interface GoogleImagesDatasourceTests : XCTestCase

@property (nonatomic, strong)GoogleImagesDatasource* datasource;

@end

@implementation GoogleImagesDatasourceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.datasource = [[GoogleImagesDatasource alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.datasource = nil;
}

- (void)testBasicQuery {
    
    XCTestExpectation *expectation =  [self expectationWithDescription:@"basic query"];

    // This is an example of a functional test case.
    self.datasource.searchString = @"test query";
    
    [self.datasource fetchBatchOnCompletion:^(NSError *error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:^(NSError *error) {
        if (error) {
            XCTFail();
        }
    }];
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
