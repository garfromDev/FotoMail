//
//  FotomailUserDefaultTests.m
//  FotoMail
//
//  Created by Alistef on 21/01/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FotomailUserDefault.h"
// CAUTION : works with Fotomail defined as target in Target/General/Host Application
// and with "allows Host API testing" checked (go to the Navigator, select Fotomail, then SimulatorFotomailTest target
@interface FotomailUserDefaultTests : XCTestCase

@end

@implementation FotomailUserDefaultTests


- (void)setUp {
    [super setUp];
    [FotomailUserDefault.defaults setImgNumber:0];
    [FotomailUserDefault.defaults setProjects:@[]];
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

// titreImg is nonnull so there is no point to test for nil
//-(void)testSetTitreImgToNil{
//
//    [FotomailUserDefault.defaults setTitreImg:nil];
//    XCTAssert([FotomailUserDefault.defaults.titreImg isEqualToString: @""],@"titreImg should be equal to empry string");
//    XCTAssert([FotomailUserDefault.defaults.nomImg isEqualToString:@"Foto_0.jpg"],@"titreImg should be equal to Foto_0.jpg");
//}


-(void)testSetTitreImgToValue{
    
    [FotomailUserDefault.defaults setTitreImg:@"SomeValue"];
    [FotomailUserDefault.defaults setImgNumber:11];
    XCTAssert([FotomailUserDefault.defaults.titreImg isEqualToString: @"SomeValue"],@"titreImg should be equal to SomeValue");
    XCTAssert([FotomailUserDefault.defaults.nomImg isEqualToString:@"SomeValue_11.jpg"],@"titreImg should be equal to SomeValue_0.jpg");
}

-(void)testSetImgNumberToValue{
    
    XCTAssert([FotomailUserDefault.defaults imgNumber] == 0, @"imgNumber doit être à zéro");
    FotomailUserDefault.defaults.imgNumber++;
    XCTAssert([FotomailUserDefault.defaults imgNumber] == 1, @"imgNumber doit être à un");
    [FotomailUserDefault.defaults setImgNumber:NSIntegerMax];
    XCTAssert([FotomailUserDefault.defaults imgNumber] == 0, @"imgNumber doit être à zéro");
}

-(void)testSetCurrentProject{
    FotomailUserDefault.defaults.currentProject = @"testProject";
    XCTAssert([[FotomailUserDefault.defaults currentProject] isEqualToString:@"testProject\\"], @"un \\ doit être ajouté à la fin");
    
    FotomailUserDefault.defaults.currentProject = @"";
    XCTAssert([[FotomailUserDefault.defaults currentProject] isEqualToString:@"\\"], @"un \\ doit être ajouté à la fin même si la chaine est vide");
}

-(void) testNextName {
    // on fixe le numero incrémental à 20, on suppose que c'est la premiere photo de la session
        
    [FotomailUserDefault.defaults setNbImages:0];
    [FotomailUserDefault.defaults nextName];
    XCTAssert([FotomailUserDefault.defaults imgNumber] == 21, @"imgNumber doit être à vingt et un");
    XCTAssertEqualObjects([FotomailUserDefault.defaults nomImg], @"Foto_21.jpg", @"titre doit etre Foto_21.jpg");
    XCTAssertEqual([FotomailUserDefault.defaults nbImages], 0, @"le no de l'image courante doit être 0, car il n'est pas incrémenté par next_name");
}
@end
