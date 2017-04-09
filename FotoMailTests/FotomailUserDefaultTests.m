//
//  FotomailUserDefaultTests.m
//  FotoMail
//
//  Created by Alistef on 21/01/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FotomailUserDefault.h"

@interface FotomailUserDefaultTests : XCTestCase

@end

@implementation FotomailUserDefaultTests

- (void)setUp {
    [super setUp];
    [FotomailUserDefault.defaults setImgNumber:0];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testSetTitreImgToEmpty{
    
    [FotomailUserDefault.defaults setTitreImg:@""];
    XCTAssert([FotomailUserDefault.defaults.titreImg isEqualToString: @""],@"titreImg should be equal to empry string");
    XCTAssert([FotomailUserDefault.defaults.nomImg isEqualToString:@"Foto_0.jpg"],@"titreImg should be equal to Foto_0.jpg");
}


-(void)testSetTitreImgToNil{
    
    [FotomailUserDefault.defaults setTitreImg:nil];
    XCTAssert([FotomailUserDefault.defaults.titreImg isEqualToString: @""],@"titreImg should be equal to empry string");
    XCTAssert([FotomailUserDefault.defaults.nomImg isEqualToString:@"Foto_0.jpg"],@"titreImg should be equal to Foto_0.jpg");
}


-(void)testSetTitreImgToValue{
    
    [FotomailUserDefault.defaults setTitreImg:@"SomeValue"];
    XCTAssert([FotomailUserDefault.defaults.titreImg isEqualToString: @"SomeValue"],@"titreImg should be equal to SomeValue");
    XCTAssert([FotomailUserDefault.defaults.nomImg isEqualToString:@"SomeValue_0.jpg"],@"titreImg should be equal to SomeValue_0.jpg");
}

-(void)testSetImgNumberToValue{
    
    XCTAssert([FotomailUserDefault.defaults imgNumber] == 0, @"imgNumber doit être à zéro");
    FotomailUserDefault.defaults.imgNumber++;
    XCTAssert([FotomailUserDefault.defaults imgNumber] == 1, @"imgNumber doit être à un");
    [FotomailUserDefault.defaults setImgNumber:NSIntegerMax];
    XCTAssert([FotomailUserDefault.defaults imgNumber] == 0, @"imgNumber doit être à zéro");    
}
@end
